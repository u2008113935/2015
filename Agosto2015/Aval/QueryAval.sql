
			Select top 5 * from KPYTCREMULCLI
	
			SELECT cCodRelCta,* FROM GENTTipRelCta	
			Where cCodSistema = 'KPY' 
				and cCodRelCta in ('E','G','B','N')				
				
			Select top 5 * from GENMCRECLI B				
	
			SELECT cCodRelCta,* FROM GENTTipRelCta	
			Where cCodSistema = 'KPY'
								

			Select G.cCodCtaCre --,G.cCodLinCre
				,A.cCodLinCre, A.cCodClient, A.cCodRelCta 
				--,B.cCodRelCta
				,B.cDesRelCta
			From GENMCRECLI G
				inner join KPYTCREMULCLI A
					on G.cCodLinCre = A.cCodLinCre 
				inner join GENTTipRelCta B
					on A.cCodRelCta = B.cCodRelCta
			Where B.cCodSistema = 'KPY'
				AND G.cCodCtaCre = '107019101002264302'
				and B.cCodRelCta in ('E','G','B','N')		


			----------------------------------------------------
			
			Select top 1 G.cCodCtaCre --,G.cCodLinCre
				,A.cCodLinCre, A.cCodClient, A.cCodRelCta 
				--,B.cCodRelCta
				,B.cDesRelCta
			From GENMCRECLI G
				inner join KPYTCREMULCLI A
					on G.cCodLinCre = A.cCodLinCre 
				inner join GENTTipRelCta B
					on A.cCodRelCta = B.cCodRelCta
			Where B.cCodSistema = 'KPY'
				AND G.cCodCtaCre = '107019101002264302'
				and B.cCodRelCta in ('E','G','B','N')	