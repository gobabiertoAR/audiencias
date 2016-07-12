class MainController < ApplicationController

  def home
  end

  def audience
    @audience = Audience.find_by_id(params[:id])
    if @audience    
      render :home
    else
      redirect_to '/404'  
    end
  end

  def search
    @search_results = search_audiences
    render :home
  end

  private 

  def search_audiences 
    search_options = params.permit([
      'buscar-persona', 'buscar-pen', 'buscar-textos', 'buscar-representado', 
      'desde', 'hasta', 'q', 'pagina', 'interes-invocado', 'persona', 'pen',
      'organismo-estatal', 'grupo-de-personas', 'persona-juridica'
    ])

    selected = {}
    if search_options.include?('persona')
      person = Person.find_by_id(search_options['persona'])
      selected['person'] = person.name if person
    end
    if search_options.include?('interes-invocado')
      selected['interest_invoked'] = search_options['interes-invocado'].titleize
    end
    if search_options.include?('pen')
      dependency = Dependency.find_by_id(search_options['pen'])
      selected['dependency'] = dependency.name if dependency
    end
    if search_options.include?('organismo-estatal')
      organism = StateOrganism.find_by_id(search_options['organismo-estatal'])
      selected['organism'] = organism.name if organism
    end
    if search_options.include?('grupo-de-personas')
      people_group = PeopleGroup.find_by_id(search_options['grupo-de-personas'])
      selected['group'] = people_group.name if people_group
    end
    if search_options.include?('persona-juridica')
      legal_entity = LegalEntity.find_by_id(search_options['persona-juridica'])
      selected['entity'] = legal_entity.name if legal_entity
    end

    page = (params[:pagina] || 1).to_i
    search_results = Audience.public_search(search_options)
    paginated_results = search_results.paginate(page: page)

    {
      audiences: paginated_results.records.as_json({for_public: true}),
      total: paginated_results.records.total,
      total_pages: paginated_results.total_pages,
      current_page: page,
      per_page: Audience.per_page,
      aggregations: search_results.response['aggregations'].as_json,
      options: search_options,
      selected_values: selected
    }
  end

end
