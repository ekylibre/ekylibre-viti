$(document).behave "load", "duke[data-current-account]", ->
  account = $(this).data('current-account')
  tenant = $(this).data('current-tenant')
  # Function that sets the tenant as a watson context element
  preSendhandler = (event) ->
    event.data.context.skills['main skill'].user_defined.tenant = tenant
    return

  window.watsonAssistantChatOptions =
    integrationID: '83d060b5-1f82-4dff-9d3b-8692d6aa8c03'
    region: 'eu-gb'
    serviceInstanceID: 'b70a176e-5c5a-4df1-a352-712aa192231d'
    onLoad: (instance) ->
      instance.render()
      instance.on
        type: 'pre:send'
        handler: preSendhandler
      instance.updateUserID account
      return

  addObserverIfNodeAvailable()
  setTimeout ->
    t = document.createElement('script')
    t.src = 'https://web-chat.global.assistant.watson.appdomain.cloud/loadWatsonAssistantChat.js'
    document.head.appendChild t
    return
basic_url = window.location.protocol + '//' + location.host.split(':')[0]
# MutationObserver to detect specific elements in Watson Responses Messages (urls)
addObserverIfNodeAvailable = ->
  targetNode = $('#WACWidget')[0];
  if !targetNode
    window.setTimeout addObserverIfNodeAvailable, 1500
    return
  link_regex = /<lien (.{10,})="" lien="">/

  callback = (mutationsList, observer) ->
    # Function that checks for mutations in the WatsonAssistantChat messages
    for mutation in mutationsList
      if mutation.target.id and mutation.target.id == 'WAC__messages' and mutation.target.innerHTML.match(link_regex)
        location.replace basic_url + mutation.target.innerHTML.match(link_regex)[1]
    return

  observer = new MutationObserver(callback)
  observer.observe targetNode,
    subtree: true
    characterData: true
    attributes: true
    childList: true
  return
