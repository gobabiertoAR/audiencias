class window.AdminMenu extends window.AbstractMenu

  constructor: ->
    @menuId = '#admin-menu'
    @listenEvents()

  listenEvents: ->
    $('#superadmin-options').on('click', @showAdminMenu)
    $('#admin-menu .user-section-add').on('click', @showNewAdminForm)
    $('#admin-menu .cancel-top-action .cancel').on('click', @showDefault)
    $('#submit-new-admin').on('click', @submitAdmin)
    $('#remove-admin').on('click', @showRemoveIcons)
    $('#supervisors-list').on('click', '.user.removable', @removeAdmin)
    $('#supervisors-list').on('click', '.user.editable', @editAdmin)
    $('#edit-admins').on('click', @showEditIcons)

  showAdminMenu: =>
    $('#admin-menu').removeClass('hidden')
      .siblings().addClass('hidden')
    @showDefault()

  showDefault: =>
    @showTopMenu()
    @showAdminList()
    @showAddIcon()

  showAdminList: ->
    $('#supervisors-list').removeClass('hidden')
    $('#new-admin-form').addClass('hidden')
    @loadAdmins()

  showAddIcon: ->
    $('#admin-menu .user-section-add').removeClass('hidden')
    $('#admin-menu .user-section-remove').addClass('hidden')
    $('#admin-menu .user-section-edit').addClass('hidden')

  hideAllIcons: ->
    $('#admin-menu .user-section-add').addClass('hidden')
    $('#admin-menu .user-section-remove').addClass('hidden')
    $('#admin-menu .user-section-edit').addClass('hidden')

  showNewAdminForm: =>
    @showCancelAction()
    $('#supervisors-list').addClass('hidden')
    $('#new-admin-form').removeClass('hidden')
    @hideAllIcons()
    @cleanForm()

  showEditForm: (admin) ->
    @showNewAdminForm()
    @populateForm(admin)

  populateForm: (admin) ->
    $('#new-admin-id').val(admin.dni).prop('disabled', true)
    $('#new-admin-name').val(admin.name)
    $('#new-admin-surname').val(admin.surname)
    $('#new-admin-email').val(admin.email)

  loadAdmins: =>
    if @admins 
      @renderAdminList()
    else
      $.getJSON('/administracion/listar_supervisores', (response) =>
        @admins = response
        @renderAdminList()
      )

  renderAdminList: =>
    adminList = $('#supervisors-list').html('')
    for admin in @admins 
      adminEl = $('<li class="user">').data('admin', admin)
      userIcon = $('<span class="user-icon">').text((admin.name[0] + admin.surname[0]).toUpperCase())
      userName = $('<div class="user-name">').text("#{admin.name} #{admin.surname}")
      userDocument = $('<div class="user-document">').text(admin.dni)
      userEmail = $('<div class="user-email">').text(admin.email)
      
      adminEl.append(userIcon)
      adminEl.append(userName)
      adminEl.append(userDocument)
      adminEl.append(userEmail)

      adminList.append(adminEl)

  showRemoveIcons: =>
    @showAdminList()
    @showCancelAction()
    $('#admin-menu .user-section-add').addClass('hidden')
    $('#admin-menu .user-section-edit').addClass('hidden')
    $('#admin-menu .user-section-remove').removeClass('hidden')
    $('#supervisors-list li.user').addClass('removable')

  showEditIcons: =>
    @showAdminList()
    @showCancelAction()
    $('#admin-menu .user-section-add').addClass('hidden')
    $('#admin-menu .user-section-remove').addClass('hidden')
    $('#admin-menu .user-section-edit').removeClass('hidden')
    $('#supervisors-list li.user').addClass('editable')

  cleanForm: ->
    $('#new-admin-form input').val('').prop('disabled', false)

  submitAdmin: =>
    newAdminData = {
      id_type: $('#new-admin-id-type').val().trim(),
      id: $('#new-admin-id').val().trim(),
      name: $('#new-admin-name').val().trim()
      surname: $('#new-admin-surname').val().trim()
      email: $('#new-admin-email').val().trim()
    }
    $('#new-admin-form input, #new-admin-form button').prop('disabled', true)
    $.post('/administracion/nuevo_supervisor', newAdminData, @createNewAdminCallback)

  createNewAdminCallback: (response) =>
    if response and response.success
      @admins = null
      @showDefault()
    else
      $('#new-admin-form input, #new-admin-form button').prop('disabled', false)

  removeAdmin: (e) =>
    admin = $(e.currentTarget).data('admin')
    data = {
      id_type: admin.id_type,
      id: admin.dni
    }
    $.post('/administracion/eliminar_supervisor', data, @removeAdminCallback)

  removeAdminCallback: (response) =>
    if response and response.success
      @admins = null
      @showDefault()

  editAdmin: (e) =>
    admin = $(e.currentTarget).data('admin')
    @showEditForm(admin)