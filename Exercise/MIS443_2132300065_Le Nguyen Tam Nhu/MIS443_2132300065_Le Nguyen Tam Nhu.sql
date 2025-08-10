/*
Question 1 (10 marks): Create a database named “yourfullname” (e.g: nguyenvana”) use PGAdmin, then create a schema name “cd” that has three tables: members, bookings and facilities 
using SQL statements. Ensure each table includes appropriate primary and foreign keys, and data types. 
Submit the SQL script as part of your answer.

*/
SELECT table_name, column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'cd' 
ORDER BY table_name, ordinal_position;




/*
Question 2 (10 marks): Write an SQL query to count the total number of bookings for each facility, ordered by the highest number of bookings first.

Expected Output Columns:
	facid (Facility ID)
	total_bookings (Total number of times the facility has been booked)
*/
select b.facid, count(b.memid) AS total_bookings 
from cd.bookings b
group by b.facid
order by total_bookings desc;






/*
Question 3 (20 marks): Write an SQL query to display all bookings with the member ID and facility name, ordered by the booking start time.
Expected Output Columns:
	bookid (Booking ID)
	memid (Member ID)
	facility_name (Facility Name)
	starttime (Booking Start Time)
	slots (Number of Slots)
*/
Select b.bookid, b.memid, f.name as facility_name, b.starttime, b.slots
from cd.bookings b
join cd.facilities f on b.facid = f.facid
ORDER BY b.starttime;



/*
Question 4 (20 marks):  Write an SQL query to display each member and their total number of bookings, ensuring that members who have never made a booking are also included.
Expected Output Columns:
	memid (Member ID)
	member_name (Member Name)
	total_bookings (Total number of bookings)
Notes: Using a Common Table Expression (CTE) will get 100% (normal 90%)
*/
with Memberbookings as (
	Select memid, count(bookid) as total_bookings
	from cd.bookings 
	group by memid)
Select m.memid, concat(m.surname, ', ', m.firstname),
	coalesce(b.total_bookings, 0) as total_bookings
	from cd.members m 
	left join Memberbookings b on b.memid = m.memid;
-- CTE


/*
Question 5 (20 marks):   Write an SQL query to display all bookings made by guests (non-members), along with the facility name, ordered by the number of slots used in descending order.
Expected Output Columns:
	bookid (Booking ID)
	facility_name (Facility Name)
	starttime (Booking Start Time)
	slots (Number of Slots)
*/
select b.bookid, f.name as facility_name, b.starttime, b.slots
from cd.bookings b
left join cd.facilities f on b.facid = f.facid
where b.memid = 0
order by b.slots desc;


/*
Question 6 (20 marks): Write an SQL query to rank members based on their largest single booking (most slots in one booking), displaying their rank alongside their largest booking. If multiple members have the same largest booking, they should have the same rank (use Window fuction)

Expected Output Columns:
	memid (Member ID)
	member_name (Member Name)
	max_slots (Largest Single Booking by Slots)
	rank (Rank Based on Max Slots)
*/
select m.memid, concat(m.surname, ', ', m.firstname) As member_name, 
	max(b.slots), dense_rank () over (order by max(b.slots) Desc) AS rank
from cd.members m
join cd.bookings b on b.memid = m.memid
group by m.memid
order by rank;
