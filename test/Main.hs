{-# LANGUAGE OverloadedStrings #-}

module Main where

import           Data.Time (fromGregorian)
import           Test.Tasty (defaultMain)
import           Test.Tasty.HUnit (assertEqual, testCase)

import           FF (getAgenda)
import           FF.Storage (DocId (DocId), runStorage)
import           FF.Types (Agenda (..), NoteView (..))

main :: IO ()
main =
    defaultMain $ testCase "getAgenda" $ do
        assertEqual "not exist" Agenda{notes = [], total = 0}
            =<< runStorage "test/data/not exist" undefined (getAgenda agendaLimit)
        assertEqual "smoke"
            Agenda
                { notes =
                    [NoteView
                        { _id = DocId "1"
                        , text = "hello"
                        , start = fromGregorian 22 11 24
                        , end = Just $ fromGregorian 17 06 19
                        }]
                , total = 1
                }
            =<< runStorage "test/data/smoke.in" undefined (getAgenda agendaLimit)
  where
    agendaLimit = Just 10
