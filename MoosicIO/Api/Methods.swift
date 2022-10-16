//
//  Methods.swift
//  Api
//
//  Created by Ярослав Стрельников on 19.10.2020.
//

import Foundation

enum ApiMethodType: String {
    case account
    case ads
    case apps
    case audio
    case board
    case database
    case docs
    case execute
    case fave
    case friends
    case gifts
    case groups
    case leads
    case likes
    case market
    case messages
    case newsfeed
    case notes
    case notifications
    case pages
    case photos
    case places
    case polls
    case search
    case stats
    case status
    case storage
    case users
    case utils
    case video
    case wall
}

struct ApiMethod {
    public enum Account {
        case banUser
        case changePassword
        case getActiveOffers
        case getAppPermissions
        case getBanned
        case getCounters
        case getInfo
        case getProfileInfo
        case getPushSettings
        case registerDevice
        case saveProfileInfo
        case setNameInMenu
        case setOffline
        case setOnline
        case setPushSettings
        case setInfo
        case setSilenceMode
        case unbanUser
        case unregisterDevice
    }
    public enum Ads {
        case addOfficeUsers
        case checkLink
        case createAds
        case createCampaigns
        case createClients
        case createLookalikeRequest
        case createTargetGroup
        case createTargetPixel
        case deleteAds
        case deleteCampaigns
        case deleteClients
        case deleteTargetGroup
        case deleteTargetPixel
        case getAccounts
        case getAds
        case getAdsLayout
        case getAdsTargeting
        case getBudget
        case getCampaigns
        case getCategories
        case getClients
        case getDemographics
        case getFloodStats
        case getLookalikeRequests
        case getOfficeUsers
        case getPostsReach
        case getRejectionReason
        case getStatistics
        case getSuggestions
        case getTargetGroups
        case getTargetPixels
        case getTargetingStats
        case getUploadURL
        case getVideoUploadURL
        case importTargetContacts
        case removeOfficeUsers
        case saveLookalikeRequestResult
        case updateAds
        case updateCampaigns
        case updateClients
        case updateTargetGroup
        case updateTargetPixel
    }
    public enum Apps {
        case deleteAppRequests
        case get
        case getCatalog
        case getFriendsList
        case getLeaderboard
        case getScore
        case sendRequest
    }
    public enum Audio {
        case get
        case getById
        case getLyrics
        case search
        case getUploadServer
        case save
        case add
        case delete
        case edit
        case reorder
        case getAlbums
        case addAlbum
        case editAlbum
        case deleteAlbum
        case moveToAlbum
        case setBroadcast
        case getBroadcastList
        case getRecommendations
        case getPopular
        case getCount
    }
    public enum Board {
        case addTopic
        case closeTopic
        case createComment
        case deleteComment
        case deleteTopic
        case editComment
        case editTopic
        case fixTopic
        case getComments
        case getTopics
        case openTopic
        case restoreComment
        case unfixTopic
    }
    public enum Database {
        case getChairs
        case getCities
        case getCitiesById
        case getCountries
        case getCountriesById
        case getFaculties
        case getRegions
        case getSchoolClasses
        case getSchools
        case getStreetsById
        case getUniversities
    }
    public enum Docs {
        case add
        case delete
        case edit
        case get
        case getById
        case getMessagesUploadServer
        case getTypes
        case getUploadServer
        case getWallUploadServer
        case save
        case search
    }
    public enum Execute {
        case execute
        case getMusicPage
        case groupsGet
    }
    public enum Fave{
        case addGroup
        case addLink
        case addUser
        case getLinks
        case getMarketItems
        case getPhotos
        case getPosts
        case getUsers
        case getVideos
        case removeGroup
        case removeLink
        case removeUser
    }
    public enum Friends{
        case add
        case addList
        case areFriends
        case delete
        case deleteAllRequests
        case deleteList
        case edit
        case editList
        case get
        case getAppUsers
        case getByPhones
        case getLists
        case getMutual
        case getOnline
        case getRecent
        case getRequests
        case getSuggestions
        case search
    }
    public enum Gifts{
        case get
    }
    public enum Groups {
        case addCallbackServer
        case addLink
        case approveRequest
        case banUser
        case create
        case deleteCallbackServer
        case deleteLink
        case edit
        case editCallbackServer
        case editLink
        case editManager
        case editPlace
        case get
        case getBanned
        case getById
        case getCallbackConfirmationCode
        case getCallbackServers
        case getCallbackSettings
        case getCatalog
        case getCatalogInfo
        case getInvitedUsers
        case getInvites
        case getMembers
        case getRequests
        case getSettings
        case invite
        case isMember
        case join
        case leave
        case removeUser
        case reorderLink
        case search
        case setCallbackSettings
        case unbanUser
    }
    public enum Leads{
        case checkUser
        case complete
        case getStats
        case getUsers
        case metricHit
        case start
    }
    public enum Likes{
        case add
        case delete
        case getList
        case isLiked
    }
    public enum Market{
        case searchadd
        case addAlbum
        case addToAlbum
        case createComment
        case delete
        case deleteAlbum
        case deleteComment
        case edit
        case editAlbum
        case editComment
        case get
        case getAlbumById
        case getAlbums
        case getById
        case getCategories
        case getComments
        case removeFromAlbum
        case reorderAlbums
        case reorderItems
        case report
        case reportComment
        case restore
        case restoreComment
        case search
    }
    public enum Messages {
        case addChatUser
        case allowMessagesFromGroup
        case createChat
        case delete
        case deleteChatPhoto
        @available(*, deprecated)
        case deleteDialog
        case deleteConversation
        case denyMessagesFromGroup
        case editChat
        @available(*, deprecated)
        case get
        case getByConversationMessageId
        case getById
        case getChat
        @available(*, deprecated)
        case getChatUsers
        case getConversations
        case getConversationsById
        case getConversationMembers
        @available(*, deprecated)
        case getDialogs
        case getHistory
        case getHistoryAttachments
        case getLastActivity
        case getLongPollHistory
        case getLongPollServer
        case isMessagesFromGroupAllowed
        @available(*, deprecated)
        case markAsAnsweredDialog
        case markAsAnsweredConversation
        case markAsImportant
        @available(*, deprecated)
        case markAsImportantDialog
        case markAsImportantConversation
        case markAsRead
        case markAsUnread
        case removeChatUser
        case restore
        case search
        case searchConversations
        @available(*, deprecated)
        case searchDialogs
        case send
        case setActivity
        case setChatPhoto
    }
    public enum NewsFeed{
        case addBan
        case deleteBan
        case deleteList
        case get
        case getBanned
        case getComments
        case getLists
        case getMentions
        case getRecommended
        case getSuggestedSources
        case ignoreItem
        case saveList
        case search
        case unignoreItem
        case unsubscribe
    }
    public enum Notes{
        case add
        case createComment
        case delete
        case deleteComment
        case edit
        case editComment
        case get
        case getById
        case getComments
        case restoreComment
    }
    public enum Notifications{
        case get
        case markAsViewed
    }
    public enum Pages{
        case clearCache
        case get
        case getHistory
        case getTitles
        case getVersion
        case parseWiki
        case save
        case saveAccess
    }
    public enum Photos{
        case confirmTag
        case copy
        case createAlbum
        case createComment
        case delete
        case deleteAlbum
        case deleteComment
        case edit
        case editAlbum
        case editComment
        case get
        case getAlbums
        case getAlbumsCount
        case getAll
        case getAllComments
        case getById
        case getChatUploadServer
        case getComments
        case getMarketAlbumUploadServer
        case getMarketUploadServer
        case getMessagesUploadServer
        case getNewTags
        case getOwnerCoverPhotoUploadServer
        case getOwnerPhotoUploadServer
        case getTags
        case getUploadServer
        case getUserPhotos
        case getWallUploadServer
        case makeCover
        case move
        case putTag
        case removeTag
        case reorderAlbums
        case reorderPhotos
        case report
        case reportComment
        case restore
        case restoreComment
        case save
        case saveMarketAlbumPhoto
        case saveMarketPhoto
        case saveMessagesPhoto
        case saveOwnerCoverPhoto
        case saveOwnerPhoto
        case saveWallPhoto
        case search
    }
    public enum Places{
        case add
        case checkin
        case getById
        case getCheckins
        case getTypes
        case search
    }
    public enum Polls{
        case addVote
        case create
        case deleteVote
        case edit
        case getById
        case getVoters
    }
    public enum Search{
        case getHints
    }
    public enum Stats{
        case get
        case getPostReach
        case trackVisitor
    }
    public enum Status{
        case get
        case set
    }
    public enum Storage{
        case get
        case getKeys
        case set
    }
    public enum Users{
        case get
        case getFollowers
        case getNearby
        case getSubscriptions
        case isAppUser
        case report
        case search
    }
    public enum Utils{
        case checkLink
        case deleteFromLastShortened
        case getLastShortenedLinks
        case getLinkStats
        case getServerTime
        case getShortLink
        case resolveScreenName
    }
    public enum Video{
        case add
        case addAlbum
        case addToAlbum
        case createComment
        case delete
        case deleteAlbum
        case deleteComment
        case edit
        case editAlbum
        case editComment
        case get
        case getAlbumById
        case getAlbums
        case getAlbumsByVideo
        case getCatalog
        case getCatalogSection
        case getComments
        case hideCatalogSection
        case removeFromAlbum
        case reorderAlbums
        case reorderVideos
        case report
        case reportComment
        case restore
        case restoreComment
        case save
        case search
    }
    public enum Wall{
        case createComment
        case delete
        case deleteComment
        case edit
        case editAdsStealth
        case editComment
        case get
        case getById
        case getComments
        case getReposts
        case pin
        case post
        case postAdsStealth
        case reportComment
        case reportPost
        case repost
        case restore
        case restoreComment
        case search
        case unpin
    }
}

extension ApiMethod {
    static func method(from type: ApiMethodType, with method: Any, hasExecute: Bool = false) -> String {
        return hasExecute ? "execute" : type.rawValue + "." + "\(method)"
    }
}
