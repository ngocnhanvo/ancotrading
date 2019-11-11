select pbg.ten_phienbangia, pbg.ngay_hieuluc, gsp.gia, bg.banggiaban
from md_giasanpham gsp
inner join md_sanpham sp on sp.md_sanpham_id = gsp.md_sanpham_id
inner join md_phienbangia pbg on pbg.md_phienbangia_id = gsp.md_phienbangia_id
inner join md_banggia bg on pbg.md_banggia_id = bg.md_banggia_id
where 
EXISTS(SELECT MAX(t2.ngay_hieuluc)
FROM md_phienbangia t2, md_banggia bg2
WHERE
	t2.md_banggia_id = bg2.md_banggia_id 
	and bg2.isstandar = 1
	and bg2.banggiaban = 0
HAVING pbg.ngay_hieuluc = MAX(t2.ngay_hieuluc)
) 
and sp.ma_sanpham = '81-00100-01-02'

select pbg.ten_phienbangia, pbg.ngay_hieuluc, gsp.gia from md_giasanpham gsp
inner join md_sanpham sp on sp.md_sanpham_id = gsp.md_sanpham_id
inner join md_phienbangia pbg on pbg.md_phienbangia_id = gsp.md_phienbangia_id
where sp.ma_sanpham = '81-00100-01-02'
order by pbg.ngay_hieuluc desc