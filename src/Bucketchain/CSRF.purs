module Bucketchain.CSRF
  ( Options
  , withCSRFProtection
  ) where

import Prelude

import Bucketchain.Http (Http, requestHeaders, requestMethod, setStatusCode, setHeader)
import Bucketchain.Middleware (Middleware)
import Bucketchain.ResponseBody (body)
import Control.Alt ((<|>))
import Control.Monad.Reader (ask)
import Data.Foldable (elem)
import Data.Maybe (Maybe(..))
import Effect.Class (liftEffect)
import Foreign.Object (lookup)

-- | The type of options.
-- |
-- | - `host`: hostname like `example.com`
-- | - `origins`: allowed origins like `[ "http://example.com" ]`
type Options =
  { host :: String
  , origins :: Array String
  }

-- | CSRF protection middleware.
withCSRFProtection :: Options -> Middleware
withCSRFProtection opts next = do
  http <- ask
  if requestMethod http == "OPTIONS" || isCorrectRequest http opts
    then next
    else liftEffect do
      setHeader http "Content-Type" "text/plain; charset=utf-8"
      setStatusCode http 403
      Just <$> body "Forbidden."

isCorrectRequest :: Http -> Options -> Boolean
isCorrectRequest http opts =
  isCorrectHost http opts.host
    && isCorrectXFrom http opts.origins
    && isCorrectOrigin http opts.origins

isCorrectHost :: Http -> String -> Boolean
isCorrectHost http host = host' == Just host
  where
    headers = requestHeaders http
    host' = lookup "host" headers <|> lookup ":authority" headers

isCorrectXFrom :: Http -> Array String -> Boolean
isCorrectXFrom http origins =
  case lookup "x-from" $ requestHeaders http of
    Nothing -> false
    Just xFrom -> elem xFrom origins

isCorrectOrigin :: Http -> Array String -> Boolean
isCorrectOrigin http origins =
  case lookup "origin" $ requestHeaders http of
    Nothing -> true
    Just origin -> elem origin origins
