-- Final Exam MIS 443 Q4 - 2024-2025 - Skeleton
-- Your ID:2132300065
-- Your Name: Lê Nguyễn Tâm Như


/*
Question 1 (10 marks): Create a database named “yourfullname” (e.g: dangthaidoan”) use PGAdmin, then create a schema name “cd” that has three tables: members, bookings and facilities 
using SQL statements. Ensure each table includes appropriate primary and foreign keys, and data types. 
Submit the SQL script as part of your answer.
*/

-- Q1.A Check tables
SELECT table_name, column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'ba' 
ORDER BY table_name, ordinal_position;

-- Q1. B. check table student
-- Your answer here
create table ba.students (
    studentid integer primary key,
    fullname  varchar(200) not null,
    email     varchar(255) not null unique);
--insert record
insert into ba.students (studentid, fullname, email)
values (2132300065, 'Le Nguyen Tam Nhu', 'nhu.lenguyen.bbs21@eiu.edu.vn');

-- End your answer

/*
Question 2 (10 marks): Write an SQL query to find the top 3 facilities that have been booked the most number of total slots (not just number of bookings).
Display their facility ID and the total number of slots booked, sorted from highest to lowest.
*/
-- Your answer here
select b.facid, sum (b.slots) as total_slots
from ba.bookings b
group by b.facid
order by total_slots desc
limit 3;

-- End your answer
/*
Question 3 (20 marks): Write an SQL query to display all bookings that lasted more than 2 slots, along with the member ID, facility ID, and facility name, 
sorted by member ID and then by start time (ascending).
*/
-- Your answer here
select b.bookid, b.memid, b.facid, f.name as facility_name, b.starttime, b.slots
from ba.bookings b
join ba.facilities f on b.facid = f.facid
where b.slots > 2
order by b.memid, b.starttime;
-- End your answer

/*
Question 4 (20 marks):  Write an SQL query to display each member and the number of bookings they made for facility ID = 1. 
Include all members, even those who have never booked that facility.
*/
-- Your answer here
select m.memid, 
       concat(m.firstname, ' ', m.surname) as member_name,
       count(b.bookid) as facility1_bookings
from ba.members m
left join ba.bookings b 
       on m.memid = b.memid and b.facid = 1
group by m.memid, member_name
order by facility1_bookings desc;
-- End your answer

/*
Question 5 (20 marks):   Write an SQL query to show the total number of slots booked by guests (memid = 0) for each facility.
Include the facility name and display the result in descending order of total slots used.
*/
-- Your answer here
select f.facid, f.name as facility_name,
    sum(b.slots) as total_guest_slots
from ba.bookings b
join ba.facilities f on b.facid = f.facid
where b.memid = 0
group by f.facid, f.name
order by total_guest_slots desc;
-- End your answer
/*
Question 6 (20 marks): Write an SQL query to rank members based on their total number of bookings. 
Members with the same number of bookings should have the same rank. Only include members who have made at least one booking
*/
-- Your answer here
select m.memid,
    concat(m.firstname, ' ', m.surname) as member_name,
    count(b.bookid) as total_bookings,
    rank() over (order by count(b.bookid) desc) as rank
from ba.members m
join ba.bookings b on m.memid = b.memid
group by m.memid, m.firstname, m.surname
order by rank;

-- End your answer
