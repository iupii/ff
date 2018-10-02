{-# LANGUAGE RecordWildCards #-}

module Gen (config, day) where

import           Prelude hiding (maybe)

import           Data.Time (Day, fromGregorian)
import           Hedgehog (MonadGen)
import           Hedgehog.Gen (bool_, maybe, string, unicode, integral)
import qualified Hedgehog.Range as Range

import           FF.Config (Config (..), ConfigUI (..))

config :: MonadGen m => m Config
config = do
    dataDir <- maybe $ string (Range.linear 1 100) unicode
    ui <- configUI
    pure Config{..}

configUI :: MonadGen m => m ConfigUI
configUI = do
    shuffle <- bool_
    pure ConfigUI{..}

day :: MonadGen m => m Day
day = fromGregorian
    <$> integral (Range.constant 0 10000)
    <*> integral (Range.constant 1 12)
    <*> integral (Range.constant 1 31)
