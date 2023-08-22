--No 1
--Key Point
-- 1. Memfilter data tahun 2021
-- 2. Mencari nilai transaksi terbesar yang sudah di bayarkan
-- 3. is_valid = 1
-- 4. Source table: order_detail
select
	to_char(order_date, 'Month') as bulan_2021,
	round(sum(after_discount)) as total_transaksi
from
	order_detail
where
	is_valid = 1
	and to_char(order_date, 'yyyy-mm-dd') between '2021-01-01' and '2021-12-31'
group by 1
order by 2 desc


--No 2
--Key Point
-- 1. Memilter transaksi pada tahun 2022
-- 2. Mencari kategori yang menghasilkan nilai transaksi terbesar
-- 3. is_valid = 1
-- 4. Source table: order_detail, sku_detail
select distinct category from sku_detail;
select
	sd.category,
	round(sum(od.after_discount)) as total_transaksi
from
	order_detail as od
	left join sku_detail as sd
	on od.sku_id = sd.id
where
	is_valid = 1
	and order_date between '2022-01-01' and '2022-12-31'
group by 1
order by 2 desc


--No 3
--Key Point:
-- 1. Memfilter data tahun 2021 dan 2022
-- 2. Mencari kategori beserta tren peningkatan dan penurunan
-- 3. is_valid = 1
-- 4. Source table: order_detail, sku_detail
with
transaksi as (
 select 
  sd.category,
  sum(case when to_char(order_date, 'yyyy-mm-dd') between '2021-01-01' and '2021-12-31'
  then od.after_discount end) as total_sales_2021,
  sum(case when to_char(order_date, 'yyyy-mm-dd') BETWEEN '2022-01-01' AND '2022-12-31'
  then od.after_discount end) as total_sales_2022
 from 
  order_detail as od
 left join
  sku_detail as sd
  on od.sku_id = sd.id
 where
  is_valid = 1
 group by
  1
)

select
 transaksi.*,
 total_sales_2022 - total_sales_2021 AS Growth,
 case
  when total_sales_2022 < total_sales_2021 then 'Menurun'
  when total_sales_2022 > total_sales_2021 then 'Meningkat'
  else 'Stagnan' 
 end as Keterangan
from 
 transaksi
order by 4 desc


--No 4:
--Key Points:
-- 1. Memilter data tahun 2022
-- 2. Mencari 5 metode pembayaran paling banyak di gunakaan berdasarkan unique order
-- 3. is_valid = 1
-- 4. Source table: order_detail dan payment_detail
select
 pd.payment_method,
 count(distinct od.customer_id) as total_pelanggan
from
 order_detail as od
left join
 payment_detail as pd
 on od.payment_id = pd.id
where 
 is_valid = 1
 and order_date between '2022-01-01' and '2022-12-31'
group by 1
order by 2 desc
limit 5


--No 5
--Key Points:
-- 1. Memfilter merk : Samsung, Apple, Sony, Huawei, Lenovo
-- 2. Sorting berdasar nilai transaksi
-- 3. Source table: order_detail, sku_detail
with a as (
select 
 case
  when lower (sd.sku_name) like '%samsung%' then 'Samsung'
  when lower (sd.sku_name) like '%iphone%' or lower (sd.sku_name) like '%ipad%'
  or lower (sd.sku_name) like '%macbook%' or lower (sd.sku_name) like '%apple%'
  then 'Apple'
  when lower (sd.sku_name) like '%sony%' then 'Sony'
  when lower (sd.sku_name) like '%huawei%' then 'Huawei'
  when lower (sd.sku_name) like '%lenovo%' then 'Lenovo'
  end as product_name,
 ROUND(sum(od.after_discount)) as total_sales
from order_detail as od
left join sku_detail as sd
 on od.sku_id = sd.id
where
 is_valid = 1
group by 1
order by 2 desc
)
select 
 a.*
from a
where product_name notnull
