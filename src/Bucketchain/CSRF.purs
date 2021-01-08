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
  if isIgnoredMethods http || isCorrectRequest http opts
    then next
    else liftEffect do
      setHeader http "Content-Type" "text/plain; charset=utf-8"
      setStatusCode http 403
      Just <$> body "Forbidden."

isIgnoredMethods :: Http -> Boolean
isIgnoredMethods http =
  elem (requestMethod http) [ "GET", "HEAD", "OPTIONS" ]

isCorrectRequest :: Http -> Options -> Boolean
isCorrectRequest http opts =
  isCorrectHost http opts && isCorrectOrigin http opts

isCorrectHost :: Http -> Options -> Boolean
isCorrectHost http { host } =
  host' == Just host
  where
    headers = requestHeaders http
    host' = lookup "host" headers <|> lookup ":authority" headers

isCorrectOrigin :: Http -> Options -> Boolean
isCorrectOrigin http { origins } =
  case lookup "x-from" headers, lookup "origin" headers of
    Just xFrom, Just origin ->
      xFrom == origin && elem origin origins
    Just _, Nothing -> true
    Nothing, _ -> false
  where
    headers = requestHeaders http
