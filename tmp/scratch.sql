SELECT DISTINCT COUNT(m.MediaId),
                m.Restriction,
                c.CollectionName,
                c.CollectionTitle,
                w.WowzaCollName
           FROM tblCollection c,
                tblWowzaCollection w,
                tblMedia m,
                tblLinkCollectionMedia c2m
          WHERE m.MediaId = c2m.MediaID
            AND m.WowzaCollectionId = w.WowzaCollectionID
            AND c2m.CollectionID = c.CollectionID
       GROUP BY c.CollectionName,
                c.CollectionTitle,
                w.WowzaCollName,
                m.Restriction
       ORDER BY 1 DESC
;

                
SELECT DISTINCT COUNT(DISTINCT(m.WowzaCollectionId)),
                m.GroupName
           FROM tblMedia m
       GROUP BY m.GroupName
       ORDER BY 1 DESC, 2
;
