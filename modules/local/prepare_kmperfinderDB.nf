// From BU-ISCIII
process PREPARE_KMERFINDERDB {
    tag "$meta.id"
    label 'process_medium'

    input:
    path(compressed_db)

    output:
    path "$database_name"

    script:
    def database_name = compressed_db.toString() - ".gz" - ".tar"
    """
    mkdir $database_name
    tar -xf ${compressed_db} -C ${database_name} --strip-components 1
    """
}
