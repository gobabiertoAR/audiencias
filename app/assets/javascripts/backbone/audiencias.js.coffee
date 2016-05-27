#= require_self
#= require_tree ./templates
#= require_tree ./models
#= require_tree ./collections
#= require_tree ./views

window.audiencias =
  views: {}
  models: {}
  collections: {}
  globals: {}
  app: {
    init: ->
      audiencias.globals.userDependencies = new audiencias.collections.UserDependencies
      audiencias.globals.users = new audiencias.collections.Users
      audiencias.globals.obligees = new audiencias.collections.Obligees
      audiencias.globals.audiences = new audiencias.collections.Audiences
      new audiencias.views.UnexpectedErrorHandler

    loadDependencies: ->
      $.ajax(
        url: '/intranet/listar_dependencias'
        method: 'GET'
        success: (response) =>
          audiencias.globals.userDependencies.set(response.dependencies)
      )

    loadUsers: ->
      $.ajax(
        url: '/intranet/listar_usuarios'
        method: 'GET'
        success: (response) =>
          audiencias.globals.users.set(response.users)
      )

    renderHeader: ->
      header = new audiencias.views.Header
      header.render()
      $('body').prepend(header.el)

    userLogin: ->
      audiencias.app.init()
      @renderHeader()
      userLogin = new audiencias.views.UserLogin
      userLogin.render()
      $('body').append(userLogin.el)

    sendPasswordReset: ->
      audiencias.app.init()
      @renderHeader()
      passwordReset = new audiencias.views.PasswordReset
      passwordReset.renderSendResetLink()
      $('body').append(passwordReset.el)

    updatePassword: (formOptions) ->
      audiencias.app.init()
      @renderHeader()
      passwordReset = new audiencias.views.PasswordReset
      passwordReset.renderUpdatePasswordForm(formOptions)
      $('body').append(passwordReset.el)

    adminLanding: ->
      audiencias.app.init()
      audiencias.app.loadDependencies()
      audiencias.app.loadUsers()

      @renderHeader()
      adminLanding = new audiencias.views.AdminLanding 
      adminLanding.render()
      $('body').append(adminLanding.el)

    operatorLanding: ->
      audiencias.app.init()
      @renderHeader()
      operatorLanding = new audiencias.views.OperatorLanding 
      operatorLanding.render()
      $('body').append(operatorLanding.el)

    audienceEditor: ->
      @renderHeader()
      audienceEditor = new audiencias.views.AudienceEditor
      audienceEditor.render()
      $('body').append(audienceEditor.el)
  }