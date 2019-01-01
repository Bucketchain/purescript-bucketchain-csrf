# purescript-bucketchain-csrf

[![Latest release](http://img.shields.io/github/release/Bucketchain/purescript-bucketchain-csrf.svg)](https://github.com/Bucketchain/purescript-bucketchain-csrf/releases)

A [Bucketchain](https://github.com/Bucketchain/purescript-bucketchain) middleware for stateless CSRF protection without token.

## Installation

```
bower install purescript-bucketchain-csrf purescript-bucketchain-cors
```

## Usage

Use with cors middleware.

```purescript
server :: Effect Server
server = createServer $ middleware1 <<< middleware2 <<< middleware3

middleware1 :: Middleware
middleware1 = withCSRFProtection
  { host: "example.oreshinya.xyz"
  , origins: [ "http://example.oreshinya.xyz", "http://test.oreshinya.xyz" ]
  }

middleware2 :: Middleware
middleware2 = withCORS defaultOptions
  { origins = Origins [ "http://example.oreshinya.xyz", "http://test.oreshinya.xyz" ]
  }

middleware3 :: Middleware
middleware3 next = do
  http <- ask
  if requestMethod http == "POST" && requestURL http == "/test"
    then liftEffect $ Just <$> body "This is test."
    else next
```

This middleware checks some headers:
- `Host`: Check if host(for DNS Rebinding).
- `X-From`: Check if allowed origin. you should send all request with this header.
- `Origin`: Check if allowed origin.

## Documentation

Module documentation is [published on Pursuit](http://pursuit.purescript.org/packages/purescript-bucketchain-csrf).

## LICENSE

MIT
