create or replace view profiles as
select
    name,
    email,
    image,
    bio
from data.users;

-- it is important to set the correct owner to the RLS policy kicks in
alter view profiles owner to api;
