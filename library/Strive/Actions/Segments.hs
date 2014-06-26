{-# LANGUAGE OverloadedStrings #-}

-- | <http://strava.github.io/api/v3/segments/>
module Strive.Actions.Segments
    ( exploreSegments
    , getSegment
    , getSegmentEfforts
    , getSegmentLeaderboard
    , getStarredSegments
    ) where

import           Data.Aeson            (encode, (.:))
import           Data.Aeson.Types      (parseEither)
import           Data.ByteString.Char8 (pack)
import           Data.ByteString.Lazy  (toStrict)
import           Data.List             (intercalate)
import           Data.Monoid           ((<>))
import           Data.Time.Clock       (UTCTime)
import           Strive.Client         (Client)
import           Strive.Objects        (EffortSummary, SegmentDetailed,
                                        SegmentExploration, SegmentLeader,
                                        SegmentSummary)
import           Strive.Types          (Page, PerPage, SegmentId)
import           Strive.Utilities      (get, paginate, queryToSimpleQuery)

-- | <http://strava.github.io/api/v3/segments/#explore>
exploreSegments :: Client -> (Double, Double, Double, Double) -> Maybe String -> Maybe Integer -> Maybe Integer -> IO (Either String [SegmentExploration])
exploreSegments client (south, west, north, east) activityType minCat maxCat = do
    object <- get client resource query
    let segments = either Left (parseEither (.: "segments")) object
    return segments
  where
    resource = "segments/explore"
    query = queryToSimpleQuery
        [ ("bounds", Just (pack bounds))
        , ("activity_type", fmap pack activityType)
        , ("min_cat", fmap (pack . show) minCat)
        , ("max_cat", fmap (pack . show) maxCat)
        ]
    bounds = intercalate "," (fmap show [south, west, north, east])

-- | <http://strava.github.io/api/v3/segments/#retrieve>
getSegment :: Client -> SegmentId -> IO (Either String SegmentDetailed)
getSegment client segmentId = get client resource query
  where
    resource = "segments/" <> show segmentId
    query = []

-- | <http://strava.github.io/api/v3/segments/#efforts>
getSegmentEfforts :: Client -> SegmentId -> Maybe (UTCTime, UTCTime) -> Page -> PerPage -> IO (Either String [EffortSummary])
getSegmentEfforts client segmentId range page perPage = get client resource query
  where
    resource = "segments/" <> show segmentId <> "/all_efforts"
    query = paginate page perPage <> queryToSimpleQuery
        [ ("start_date_local", fmap (toStrict . encode . fst) range)
        , ("end_date_local", fmap (toStrict . encode . snd) range)
        ]

-- | <http://strava.github.io/api/v3/segments/#leaderboard>
getSegmentLeaderboard :: Client -> SegmentId -> Maybe Char -> Maybe String -> Maybe String -> Maybe Bool -> Maybe Integer -> Maybe String -> Page -> PerPage -> IO (Either String [SegmentLeader])
getSegmentLeaderboard client segmentId gender ageGroup weightClass following clubId dateRange page perPage = do
    object <- get client resource query
    let leaders = either Left (parseEither (.: "entries")) object
    return leaders
  where
    resource = "segments/" <> show segmentId <> "/leaderboard"
    query = paginate page perPage <> queryToSimpleQuery
        [ ("gender", fmap (pack . show) gender)
        , ("age_group", fmap pack ageGroup)
        , ("weight_class", fmap pack weightClass)
        , ("following", fmap (toStrict . encode) following)
        , ("club_id", fmap (pack . show) clubId)
        , ("date_range", fmap pack dateRange)
        ]

-- | <http://strava.github.io/api/v3/segments/#starred>
getStarredSegments :: Client -> Page -> PerPage -> IO (Either String [SegmentSummary])
getStarredSegments client page perPage = get client resource query
  where
    resource = "segments/starred"
    query = paginate page perPage
