#= require ./user_list
class audiencias.views.SupervisorList extends audiencias.views.UserList
  title: 'Supervisores'

  initialize: ->
    super()
    $(window).on('globals:users:loaded', @filterUsers)

  filterUsers: =>
    @users = _.filter(audiencias.globals.users, (u) -> u.role == 'superadmin')
    @render()

  addUserFromForm: =>
    validation = @validateUser('.new-user-form')
    if validation.valid
      @submitNew(validation.data)

  submitNew: (userData) =>
    $.ajax(
      url: '/administracion/nuevo_supervisor'
      data: { user: userData }
      method: 'POST'
      success: audiencias.globals.loadUsers
    )

  submitEdit: =>
    editedUsers = @$el.find('.user.edited')
    requests = []
    for editedUser in editedUsers
      newData = $(editedUser).data('user')
      requests.push($.ajax(
        url: '/administracion/actualizar_usuario'
        data: {user: newData }
        method: 'POST'
      ))
    $.when.apply($, requests).done(audiencias.globals.loadUsers)

  submitRemove: =>
    removedUsers = @$el.find('.user.removed')
    requests = []
    for user in removedUsers
      userData = $(user).data('user')
      requests.push($.ajax(
        url: '/administracion/eliminar_supervisor'
        data: { user: userData } 
        method: 'POST'
      ))
    $.when.apply($, requests).done(audiencias.globals.loadUsers)