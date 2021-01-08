# purescript-bucketchain-csrf

[![Latest release](http://img.shields.io/github/release/Bucketchain/purescript-bucketchain-csrf.svg)](https://github.com/Bucketchain/purescript-bucketchain-csrf/releases)

A [Bucketchain](https://github.com/Bucketchain/purescript-bucketchain) middleware for stateless CSRF protection without token.

## Installation

### Bower

```
$ bower install purescript-bucketchain-csrf
```

### Spago

```
$ spago install bucketchain-csrf
```

## Usage

```purescript
server :: Effect Server
server = createServer $ middleware1 <<< middleware2

middleware1 :: Middleware
middleware1 = withCSRFProtection
  { host: "example.oreshinya.xyz"
  , origins: [ "http://example.oreshinya.xyz" ]
  }

middleware2 :: Middleware
middleware2 next = do
  http <- ask
  case requestMethod http, requestURL http of
    "POST", "/test" ->
      liftEffect $ Just <$> body "This is test."
    "GET", "/" ->
      liftEffect $ Just <$> body "This is text."
    _, _ ->
      next
```

This middleware needs 3 headers:
- `Host`: Browsers send it automatically.
- `X-From`: You should send all request with this header.
- `Origin`: Browsers send it automatically.

## Documentation

Module documentation is [published on Pursuit](http://pursuit.purescript.org/packages/purescript-bucketchain-csrf).

## LICENSE

MIT
