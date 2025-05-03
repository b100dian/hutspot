import QtQuick 2.0
import Amber.Web.Authorization 1.0
import Nemo.Configuration 1.0

Item {
property alias oauth: oAuth

ConfigurationGroup {
    path: "/org/wdehoog/hutspot/configuration/oauth"
    id: storage

    property string accessToken: ""
    property int expiresOn: 0
    property string refreshToken: ""

    property bool linked: false
}

OAuth2AcPkce {
    id: oAuth

    signal linkingSucceeded()
    signal linkingFailed(int code, string message)

    readonly property alias accessToken: storage.accessToken
    readonly property alias expiresOn: storage.expiresOn
    readonly property alias refreshToken: storage.refreshToken


    clientId: "388f2d2f105b45ef95e159ac87ef5733"
    clientSecret: "c926747234ef4fc8aefb2759f2c3d571"
    redirectListener.port: 7357

    tokenEndpoint: "https://accounts.spotify.com/api/token"
    authorizationEndpoint: "https://accounts.spotify.com/authorize"

    onErrorOccurred: {
        storage.linked = false;
        console.log("AmberO2", "errorOccured", JSON.stringify(error))
        linkingFailed(error.code, error.message)
    }

    onReceivedAccessToken: {
        console.log("AmberO2", "receivedAccessToken: ", JSON.stringify(token))
        storage.linked = true;

        storage.accessToken = token.access_token
        // expiresIn converted to ms
        storage.expiresOn = new Date().getTime()/1000 + token.expires_in;
        storage.refreshToken = token.refresh_token
        linkingSucceeded()
    }

    onReceivedAuthorizationCode: {
        console.log("AmberO2", "receivedAuthorisationCode")
    }

    function doO2Auth() {
        console.log("AmberO2", "doO2Auth");
        authorizeInBrowser()
    }

    function isLinked() {
        return storage.linked;
    }

    function doRefreshToken() {
        console.log("AmberO2", "refreshToken");
        refreshAccessToken(storage.refreshToken);
    }
}
}
