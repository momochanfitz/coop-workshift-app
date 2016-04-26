class User < ActiveRecord::Base
    has_secure_password
    validates :email, uniqueness: true, format: { with: /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/,
    message: ": an email is incorrectly formatted" }
    validates :first_name, presence: true
    validates :last_name, presence: true
    before_create :check_attrs_exist
    

    has_attached_file :avatar, styles: { profile: "150x150>", thumb: "100x100>" }, default_url: "https://socialbelly.com/assets/icons/blank_user-586bd979abac4d7c7007414f5e94fe71.png"
    validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\Z/
    
    belongs_to :unit
    has_many :shifts
    has_many :workshifts
    has_many :preferences
    has_many :avails
    
    PERMISSION = {
          :member => 0, :manager => 1, :ws_manager =>2
    }
    
    def self.import(file)
        spreadsheet = open_spreadsheet(file)
        header = spreadsheet.row(1)
        added = []
        errors = []
        (2..spreadsheet.last_row).each do |i|
          row = Hash[[header, spreadsheet.row(i)].transpose]
          user = find_by(email: row["email"]) || new
          user.attributes = row.to_hash.slice(*row.to_hash.keys)
          user.password = User.random_pw
          if (not user.sent_confirmation) and user.save
            added += [user]
          else
            errors += [user.errors]
          end
        end
        if errors.blank?
          return added else return errors end
    end
    
    def self.open_spreadsheet(file)
      case File.extname(file.original_filename)
        when ".csv" then Roo::CSV.new(file.path, csv_options: {encoding: "iso-8859-1:utf-8"})
        else raise "Unknown file type: #{file.original_filename}"           
      end
    end
    
    def full_name
      self.first_name.capitalize + " " + self.last_name.capitalize
    end
    
    def self.send_confirmation(id)
      user = find(id)
      if user
        mg_client = Mailgun::Client.new Rails.application.secrets.api_key
        user.update_attributes!(:sent_confirmation => true)
        new_password = User.random_pw
        user.update_attribute(:password, new_password)
        message_params = {
                          :from    => Rails.application.secrets.username,
                          :to      => user.email,
                          :subject => 'Welcome to Coop Workshift',
                          :text    => 'Your temporary password is ' + new_password + ' be sure to change this when you sign in.'
                        }
        # mg_client.send_message(Rails.application.secrets.domain, message_params)
      else
      end
    end
    
    def self.random_pw
      x = ('0'..'z').to_a.shuffle.first(8).join
      return x
    end
    
    def has_saved_availability?
      self.avails.length > 0
    end
    
    def is_ws_manager?
      permissions == PERMISSION[:ws_manager]
    end
    
    def is_manager?
      permissions == PERMISSION[:manager]
    end
    
    def manager_rights?
      permissions >= PERMISSION[:manager]
    end 
    
    def is_member?
      permissions == PERMISSION[:member]
    end 
    
    def self.getPermissionCode(role)
      return PERMISSION[role.to_sym]
    end
    
    def getPermission
      if is_member?
        return "Member"
      elsif is_manager?
        return "Manager"
      else
        return "Workshift-Manager"
      end
    end
    
    def self.get_rankings_for ws 
      # USER                              PREFERENCE                                  METASHIFT                 
      # id first_name last_name unit_id   id user_id metashift_id rating cat_rating   id category name unit_id  
      
      # WORKSHIFT                                  AVAIL 
      # id metashift_id start_time end_time day    id day hour user_id status
      
      
      SELECT user.full_name, preference.get_rating 
      FROM user, preference, metashift, workshift, avail
      WHERE workshift.id = ws.id
      AND metashift.id = workshift.metashift_id
      AND preference.metashift_id = metashift.id
      AND user.id = preference.user_id
      ORDER BY preference.get_rating DESC
      
      SELECT user.full_name 
      FROM user, avail, workshift
      WHERE workshift.id = ws.id 
      AND avail.day = workshift.day
      AND user.id = avail.user_id
      AND avail.status != "Unavailable"
      AND avail.hour IN workshift.start_time to workshift.end_time
      
      
      
    end
    
    def is_available? workshift
      avail = true
      start_time = convert_to_military workshift.start_time
      end_time = convert_to_military workshfit.end_time
      day = Preference.day_mapping.key(workshift.day)
      
      (start_int...start_int+duration).each do |hour_int|
        a = self.avails.where(day: day_int, hour: hour_int).first
        if not a or a.status == "Unavaiable" or a.status == ""
          return false
        end
      end
      return avail
    end
    
    def convert_to_military time
      matcher = /^(\d?\d)(a|p)m$/
      time = matcher =~ time
      hour, ampm = $1.to_i, $2
      if ampm == 'p'
        hour + 12
      else
        hour
      end
    end
    
    def is_available? day_int, start_int, duration=1
      avail = true
      (start_int...start_int+duration).each do |hour_int|
        a = self.avails.where(day: day_int, hour: hour_int).first
        if not a or a.status == "Unavaiable" or a.status == ""
          return false
        end
      end
      return avail
    end
    
    private
    def check_attrs_exist
      if (self.compensated_hours.blank?)
        self.compensated_hours = 0
      end
      if (self.permissions.blank?)
        self.permissions = PERMISSION[:member]
      end
    end
end
