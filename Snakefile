"""
File that runs analysis for Ruiya's SARSr-CoV pools.

Written by Alexander Tendu.

Updated 20-Nov-2023.

"""

CONDITIONS = glob_wildcards("reads/{bat_pool}_1.fq.gz").bat_pool
print("bat_pool are: ", CONDITIONS)

rule all:
   input:
       blastn_out = expand("blast_out/blastn_{bat_pool}.csv",bat_pool=CONDITIONS)

#this rule cleans reads by trimming low quality ends and dropping shorter reads resulting from trimming
rule trim_reads:
   output:
       r1 = "trimmed/{bat_pool}_1_val_1.fq.gz",
       r2 = "trimmed/{bat_pool}_2_val_2.fq.gz"
   input:
       r1 = "reads/{bat_pool}_1.fq.gz",
       r2 = "reads/{bat_pool}_2.fq.gz"
   params:
       q = 29,
       stringency = 3,
       length = 100,
       max_n = 50,
       outdir = "/home/tendu/nov20_mon/trimmed/"
   threads: 16
   shell:
       """
         trim_galore --illumina\
           -o {params.outdir}\
           -q {params.q}\
           --length {params.length}\
           --stringency {params.stringency}\
           --max_n {params.max_n}\
           --paired {input.r1} {input.r2}
       """
#this rule will filter the reads to remove host related sequences by searching against the SILVA DB
rule silva_filtration:
    output:
        wantedf = "silva_filtered/wanted_{bat_pool}_fwd.fq.gz",
        wantedr = "silva_filtered/wanted_{bat_pool}_rev.fq.gz",
        unwantedf = "silva_unwanted/unwanted_{bat_pool}_fwd.fq.gz",
        unwantedr = "silva_unwanted/unwanted_{bat_pool}_rev.fq.gz"
    input:
        ref1="db/smr_v4.3_default_db.fasta",
        reads1 ="trimmed/{bat_pool}_1_val_1.fq.gz",
        reads2 = "trimmed/{bat_pool}_2_val_2.fq.gz"
    threads: 16
    params:
        ali = "silva_unwanted/unwanted_{bat_pool}",
        filt = "silva_filtered/wanted_{bat_pool}",
        kvdb = "silva_filtered/{bat_pool}/"
    shell:
        """
        sortmerna\
        --ref {input.ref1}\
        --reads {input.reads1}\
        --reads {input.reads2}\
        --aligned {params.ali}\
        --other {params.filt}\
        --kvdb {params.kvdb}\
        --fastx\
        --paired_out\
        --out2
        """
#assembly using spades;
rule spades_assembly:
    output:
        contigs = "spades_out/{bat_pool}/contigs.fasta",
        scaffolds = "spades_out/{bat_pool}/scaffolds.fasta"
    input:
        right1 ="silva_filtered/wanted_{bat_pool}_fwd.fq.gz",
        left1 ="silva_filtered/wanted_{bat_pool}_rev.fq.gz"
    params:
        outputdir = "spades_out/{bat_pool}/"
    threads: 16
    shell:
        """
        spades.py -1 {input.right1}\
        -2 {input.left1}\
        -o {params.outputdir}\
        -k 21,33,55\
        --careful\
        --disable-gzip-output
        """
#this rule makes a blast database in the current working directory
rule makeblastdb:
   input:
       reference = "db_cov_small_1356.fasta"
   output:
       the_dbase = directory("blastdb/")
   params:
       version = 5,
       title = "db_cov_small_1356",
       type = "nucl",
       odir = "blastdb/"
   shell:
       """
	   mkdir {output.the_dbase}
	   makeblastdb\
	   -in {input.reference}\
       -parse_seqids\
       -title {params.title}\
	   -blastdb_version {params.version}\
	   -dbtype {params.type}\
	   -out db_cov_small_1356
	   """
#this rule uses contigs as queries to look for similar sequences in the blast database created above
rule search_database:
   output:
       blastn_out = "blast_out/blastn_{bat_pool}.csv"
   input:
       queries = "spades_out/{bat_pool}/contigs.fasta",
       blastdb = rules.makeblastdb.output.the_dbase
   threads : 4
   params:
        evalue = 0.00001,
        blastdb = "db_cov_small_1356"
   shell:
        """
		blastn\
		-db {params.blastdb}\
		-query {input.queries}\
		-out {output.blastn_out}\
		-outfmt "6 delim= qseqid qlen sseqid sacc slen length pident qstart qend sstart send evalue qframe sframe"\
		-subject_besthit\
		-evalue {params.evalue}
		"""