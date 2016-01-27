desc "Uses multi-site to create unique db for site"
task "db:test_multi_site" => :environment do

    1.upto(20) do
        NAME = DateTime.now.to_i.to_s
        HOST = "dotforum-dev.cmttcuelhphg.us-west-2.rds.amazonaws.com"
        USERNAME = "topspectrum"
        PASSWORD = "ys--D_7E_LNL4VY"
        PERMS = "--host=#{HOST} --username=#{USERNAME} -T dotforum-template"
        PREFIX = ""

        p "#{PREFIX} createdb #{PERMS} #{NAME}"
        p `#{PREFIX} createdb #{PERMS} #{NAME}`
        p `#{PREFIX} psql #{PERMS} #{NAME} <<< "alter schema public owner to topspectrum;"`
        p `#{PREFIX} psql #{PERMS} #{NAME} <<< "create extension if not exists hstore;"`
        p `#{PREFIX} psql #{PERMS} #{NAME} <<< "create extension if not exists pg_trgm;"`

        name_forum = NAME + '.forum'
        inserts = [name_forum, "postgresql", NAME, HOST, USERNAME, PASSWORD]
        inserts.map! { |e| "'" + e + "'" }
        sql = "INSERT INTO databases (name, adapter, database, host, username, password) VALUES (#{inserts.join(', ')})"
        p ActiveRecord::Base.connection.execute(sql)
        sql = "SELECT id from databases where name='#{name_forum}'"
        result = ActiveRecord::Base.connection.execute(sql)
        id = result.getvalue(0, 0).to_i
        fail "insert into 'databases' failed" unless id.to_i > 0

        host_sql = "INSERT INTO host_names (name, database_id) VALUES ('#{name_forum}', #{id})"
        p "name_forum = #{name_forum}"
        p ActiveRecord::Base.connection.execute(host_sql)
        sleep(1)
    end
end

task "db:delete_xtra" do
    sql = "SELECT id,name from databases"
    result = ActiveRecord::Base.connection.execute(sql)
    id = result.getvalue(0, 0).to_i
    name = result.getvalue(0, 1).to_s
    p id, name
end
