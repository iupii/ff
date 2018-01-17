{-# OPTIONS_GHC -Wno-orphans #-}

{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE TemplateHaskell #-}

module FF.Types where

import           CRDT.LamportClock (LamportTime (LamportTime), Pid)
import           CRDT.LWW (LWW (LWW), time, value)
import           Data.Aeson (FromJSON, ToJSON, Value (Array), parseJSON, toJSON)
import           Data.Aeson.TH (defaultOptions, deriveJSON)
import           Data.Aeson.Types (typeMismatch)
import           Data.Foldable (toList)
import           Data.Map.Strict (Map)
import           Data.Semigroup (Semigroup, (<>))
import           Data.Semilattice (Semilattice)
import           Data.Text (Text)
import           Data.Time (Day)
import           GHC.Exts (fromList)

import           FF.Storage (Collection, DocId, collectionName)

deriveJSON defaultOptions ''Pid

instance FromJSON a => FromJSON (LWW a) where
    parseJSON (Array a) = case toList a of
        [valueJ, timeJ, pidJ] -> LWW <$> parseJSON valueJ <*> parseTime
          where
            parseTime = LamportTime <$> parseJSON timeJ <*> parseJSON pidJ
        _ -> fail $ unwords
            ["expected array of 3 values, got", show $ length a, "values"]
    parseJSON v = typeMismatch "Array" v

instance ToJSON a => ToJSON (LWW a) where
    toJSON LWW{value, time = LamportTime time pid} =
        Array $ fromList [toJSON value, toJSON time, toJSON pid]

data Status = Active | Archived | Deleted
    deriving (Eq, Show)

deriveJSON defaultOptions ''Status

data Note = Note
    { status  :: !(LWW Status)
    , text    :: !(LWW Text)
    , start   :: !(LWW Day)
    , end     :: !(LWW (Maybe Day))
    }
    deriving (Eq, Show)

instance Semigroup Note where
    Note status1 text1 start1 end1 <> Note status2 text2 start2 end2 = Note
        (status1 <> status2) (text1 <> text2) (start1 <> start2) (end1 <> end2)

instance Semilattice Note

deriveJSON defaultOptions ''Note

instance Collection Note where
    collectionName = "note"

type NoteView = Text

type Agenda = Map (DocId Note) NoteView