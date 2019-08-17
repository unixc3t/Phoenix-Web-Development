import { Presence } from 'phoenix'
import $ from 'jquery'

//const socket = new Socket('/socket')
// Connect to the socket itself
//socket.connect()

let presences = {}
let idleTimeout = null
const TIMEOUT = 30 * 1000
const hideChatUI = () => {
  $('div.chat-ui').addClass('hidden')
}
const showChatUI = () => {
  $('div.chat-ui').removeClass('hidden')
}
const pushMessage = (channel, author, message) => {
  resetTimer(channel, author)

  channel
    .push('new_message', { author, message })
    .receive('ok', res => console.log('Message sent!'))
    .receive('error', res => console.log('Failed to send message:', res))
}
const onJoin = (res, channel) => {
  $('.chat-send').on('click', event => {
    event.preventDefault()
    const chatInput = $('.chat-input').val()
    const author = $('.author-input').val()
    pushMessage(channel, author, chatInput)
    $('.chat-input').val('')
  })
  console.log('chat Joined channel:', res)
}

const addMessage = (author, message) => {
  const chatLog = $('.chat-messages').append(
    `<li>
      <span class="author">&lt;${author}&gt;:</span>
      <span class="message">${message}</span>
     </li>
    `
  )
}

const loadChat = socket => {
  $('.join-chat').on('click', () => {
    const username = $('.author-input').val()
    if (username.length <= 0) {
      return
    }
    showChatUI()
    connect(
      socket,
      username
    )
  })
}

const getStatus = metas => metas.length > 0 && metas[0]['status']

const resetTimer = (channel, username, skipPush = false) => {
  if (!skipPush) {
    channel.push('user_active', { username })
  }
  clearTimeout(idleTimeout)
  idleTimeout = setTimeout(() => {
    channel.push('user_idle', { username })
  }, TIMEOUT)
}

const syncUserList = presences => {
  console.log('syncUserlist-presences', presences)
  $('.username-list').empty()
  Presence.list(presences, (username, { metas }) => {
    const status = getStatus(metas)
    $('.username-list').append(`<li class="${status}">${username}</li>`)
  })
}

const addStatusMessage = (username, status) => {
  $('.chat-messages').append(
    `<li class="status">${username} is ${status}...</li>`
  )
}

// When Phoenix reports a change in Presence status, determine the differences
// and report the changes to the user
const handlePresenceDiff = diff => {
  // Separate out the response from the server into joins and leaves
  console.log('handlePresenceDiff-diff', diff)
  const { joins, leaves } = diff
  if (!joins && !leaves) {
    // Throw out the diff if we're missing both joins and leaves!
    return
  }
  // Next, based on the diff, get the new state of the presences variable
  presences = Presence.syncDiff(presences, diff)
  console.log('handlePresenceDiff-presences-after-sync-diff', presences)
  // Sync up the user list to the new state
  syncUserList(presences)
  // For all new statuses, add status messages to the chat log.
  Object.keys(joins).forEach(username => {
    const metas = joins[username]['metas']
    const status = getStatus(metas)
    addStatusMessage(username, status)
  })
  // Finally, display messages for each person that leaves the chat too!
  Object.keys(leaves).forEach(username => {
    if (Object.keys(joins).indexOf(username) !== -1) {
      return
    }
    addStatusMessage(username, 'gone')
  })
}

const handlePresenceState = state => {
  presences = Presence.syncState(presences, state)
  console.log('handlepresenceState:', presences)
  syncUserList(presences)
}

function testdiff(hello) {
  console.log(hello)
}
const connect = (socket, username) => {
  // Only connect to the socket if the chat channel actually exists!
  const enableLiveChat = $('enable-chat-channel')
  //console.log('enablelivechat', enableLiveChat)
  if (!enableLiveChat) {
    return
  }

  const chatroom = document
    .getElementById('enable-chat-channel')
    .getAttribute('data-chatroom')
  // Create a channel to handle joining/sending/receiving
  const channel = socket.channel('chat:' + chatroom, { username })

  // Next, join the topic on the channel!
  channel
    .join()
    .receive('ok', res => onJoin(res, channel))
    .receive('error', res => console.log('Failed to join channel:', res))

  channel.on('new_message', ({ author, message }) => {
    addMessage(author, message)
  })

  channel.on('presence_state', handlePresenceState)
  channel.on('presence_diff', handlePresenceDiff)
  channel.on('diffzz', testdiff)
  resetTimer(channel, username, true)
}

// Finally, export the socket to be imported in app.js
export default { loadChat }
