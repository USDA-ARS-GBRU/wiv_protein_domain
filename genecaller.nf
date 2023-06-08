#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

/*
 * Defines the pipeline input parameters (with a default value for each one).
 * Each of the following parameters can be specified as command line options.
 */
params.query = "$baseDir/rdrp_contigs.fa"
params.out = "$baseDir/rdrp_genes.faa"
params.chunkSize = 35000

workflow {
/*
* Create a channel emitting the given query fasta file(s).
Split the file into chunks containing as many sequences as defined by the parameter 'chunkSize'.
* Finally, assign the resulting channel to the variable 'ch_fasta'
*/
    Channel
    .fromPath(params.query)
    .splitFasta(by: params.chunkSize, file:true)
    .set { ch_fasta }
/*
* Execute a prodigal job for each chunk emitted by the 'ch_fasta' channel
* and emit the resulting prodigal translations.
*/
    ch_cds = prodigal(ch_fasta)
/*
* Collect all the sequences files into a single file
* and print the resulting file contents when complete.
*/

    ch_cds
    .collectFile(name: params.out)
    }

process prodigal {
    input:
    path 'query.fa'

    output:
    path 'called_genes'
    """
    module load prodigal
    prodigal -i query.fa -a called_genes -p meta -q
    """
}

