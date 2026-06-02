function handler(event) {
    var request = event.request;

    // API clients (SDKs, curl) don't send text/html in Accept — pass through
    var accept = request.headers.accept ? request.headers.accept.value : '';
    if (accept.indexOf('text/html') === -1) {
        return request;
    }

    // Cognito OAuth callback is a browser redirect — must not be blocked
    if (request.uri.startsWith('/api/auth/')) {
        return request;
    }

    // Browser request — require Basic Auth
    var expected = 'Basic ${credentials}';
    if (request.headers.authorization && request.headers.authorization.value === expected) {
        return request;
    }

    return {
        statusCode: 401,
        statusDescription: 'Unauthorized',
        headers: { 'www-authenticate': { value: 'Basic realm="Langfuse"' } }
    };
}
