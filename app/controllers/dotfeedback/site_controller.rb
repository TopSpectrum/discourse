module Dotfeedback
  #
  # Controller for dotfeedback sites
  #
  class SiteController < ApplicationController

    skip_before_filter :verify_authenticity_token

    DATABASE_ADAPTER = "postgresql"
    TEMPLATE_NAME = "dotforum-template"
    CONFIG = "--host=#{ENV['DOTFEEDBACK_DATABASE_HOST']} --username=#{ENV['DOTFEEDBACK_DATABASE_USERNAME']} -T #{TEMPLATE_NAME}"

    def create
      name = params[:name]
      create_db(name)
      update_dotfeedback_tables(name)

      respond_to do |format|
        format.html { "OK" }
        format.json { render json: { successful: true } }
      end
    end

    private

    def create_db(name)
      # TODO: Move this to using ActiveRecord
      Rails.logger.info "Sending createdb #{CONFIG} #{name}"
      Rails.logger.info `createdb #{CONFIG} #{name}`
      Rails.logger.info `psql #{CONFIG} #{name} <<< "alter schema public owner to topspectrum;"`
      verify_exists(name)
    end

    def update_dotfeedback_tables(name)
      ActiveRecord::Base.transaction do
        begin
          database = create_database(name)
          create_host_name(name, database.id)
        rescue => ex
          Rails.logger.error ex.message
        end
      end
    end

    def create_database(name)
      database = Database.new(
        name: name,
        adapter: DATABASE_ADAPTER,
        database: name,
        host: ENV['DOTFEEDBACK_DATABASE_HOST'],
        username: ENV['DOTFEEDBACK_DATABASE_USERNAME'],
        password: ENV['DOTFEEDBACK_DATABASE_PASSWORD'])

      database.save
      database = Database.where(name: name).first
      return database
    end

    def create_host_name(name, database_id)
      fail "Couldn't create host_name with database_id #{database_id}" unless database_id.to_i > 0
      host_name = HostName.new(
        name: name,
        database_id: database_id)

      host_name.save
      return host_name
    end

    def verify_exists(name)
      sql = "SELECT datname FROM pg_catalog.pg_database where datname='#{name}'"
      result = ActiveRecord::Base.connection.execute(sql)
      db_name = result.getvalue(0, 0).to_s
      fail "Failed to create db #{name} wuth createdb" unless name == db_name
    end
  end
end
