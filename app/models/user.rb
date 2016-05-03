class User < ActiveRecord::Base

	validates :name, presence: true
	validates :surname, presence: true
	validates :email, format: { with: GLOBALS::EMAIL_REGEX }, uniqueness: { case_sensitive: false }
	validates :dni, presence: true, uniqueness: true
	validates_numericality_of :dni, only_integer: true, greater_than: 0
	validates :password, length: { minimum: 6 }, allow_nil: true
	validates :auth_token, uniqueness: true

	has_secure_password
	before_create { generate_token(:auth_token) }
	before_save { self.email = email.downcase }

	has_many :admin_associations
	has_many :dependencies, through: :admin_associations
	has_many :operator_associations
	has_many :obligees, through: :operator_associations

	def generate_token(column)
		begin
			self[column] = SecureRandom.urlsafe_base64
		end while User.exists?(column => self[column])
	end

	def send_password_reset
		generate_token(:password_reset_token)
		self.password_reset_sent_at = Time.zone.now
		save!
		UserMailer.password_reset(self).deliver
	end

	def as_json(options={})
		super({
			only: [:dni, :id_type, :email, :id, :is_superadmin, :name, :surname, :telephone]
		})
	end

	def self.find_by_document(id_type, id)
		id_type = id_type.strip.downcase
		id = id.to_i
		where(id_type: id_type, dni: id).first
	end
end
