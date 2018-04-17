\echo # Loading roles privilege

-- this file contains the privileges of all aplications roles to each database entity
-- if it gets too long, you can split it one file per entity

-- set default privileges to all the entities created by the auth lib
select auth.set_auth_endpoints_privileges('api', :'anonymous', enum_range(null::data.user_role)::text[]);

-- specify which application roles can access this api (you'll probably list them all)
-- remember to list all the values of user_role type here
grant usage on schema api to anonymous, webuser;

-- enable RLS on the table holding the data
-------------------------------------------------------------------------------
-- user privileges
alter table data.users enable row level security;
create policy user_access_policy on data.users to api
using (
	true
)
with check (
	(request.user_role() = 'webuser' and request.user_name() = name)
);
grant select, insert, update, delete on data.users to api;
grant select, insert, update, delete on api.profiles to webuser;
grant select on api.profiles to anonymous;
-------------------------------------------------------------------------------
