class LegalEntity < ActiveRecord::Base

  validates_inclusion_of :country, :in => GLOBALS::COUNTRIES, allow_blank: true
  validates :name, length: { maximum: 200 }, presence: true
  validates :email, format: { with: GLOBALS::EMAIL_REGEX }, length: { maximum: 100 }, allow_blank: true
  validates :telephone, length: { maximum: 20 }, allow_blank: true
  validates :cuit, length: { maximum: 20 }, allow_blank: true

  def update_minor_attributes(params)
    self.country = params[:country] if params.include?(:country)
    self.name = params[:name].mb_chars if params.include?(:name)
    self.cuit = params[:cuit] if params.include?(:cuit)
    self.email = params[:email] if params.include?(:email)
    self.telephone = params[:telephone] if params.include?(:telephone)
  end

  AS_JSON_OPTIONS = {
    only: [:id, :country, :name, :email, :telephone, :cuit]
  }
  AS_PUBLIC_JSON_OPTIONS = {
    only: [:id, :country, :name, :cuit]
  }
  def as_json(options={})
    if options[:minimal]
      super({ only: [:id, :name] })
    else
      super(AS_JSON_OPTIONS)
    end
  end

end