module Main where

import Prelude

import Bucketchain (createServer, listen)
import Bucketchain.CORS (withCORS, defaultOptions)
import Bucketchain.CSRF (withCSRFProtection)
import Bucketchain.Http (requestMethod, requestURL)
import Bucketchain.Middleware (Middleware)
import Bucketchain.ResponseBody (body)
import Control.Monad.Reader (ask)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Class (liftEffect)
import Node.HTTP (ListenOptions, Server)

main :: Effect Unit
main = server >>= listen opts

server :: Effect Server
server = createServer $ middleware1 <<< middleware2 <<< middleware3

opts :: ListenOptions
opts =
  { hostname: "127.0.0.1"
  , port: 3000
  , backlog: Nothing
  }

middleware1 :: Middleware
middleware1 = withCSRFProtection
  { host: "localhost:3000"
  , origins: [ "http://localhost:3000", "http://localhost:3001" ]
  }

middleware2 :: Middleware
middleware2 = withCORS defaultOptions

middleware3 :: Middleware
middleware3 next = do
  http <- ask
  if requestMethod http == "POST" && requestURL http == "/test"
    then liftEffect $ Just <$> body "This is test."
    else next
