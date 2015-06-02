import org.apache.spark.mllib.linalg.{Vectors,Vector}
import org.apache.spark.mllib.linalg.distributed.{RowMatrix, MatrixEntry, CoordinateMatrix, BlockMatrix}
import org.apache.spark.rdd.RDD

def rddToCoordinateMatrix(input_rdd: RDD[String]) : CoordinateMatrix = {

    // Convert RDD[String] to RDD[Tuple3]
    val coo_matrix_input: RDD[Tuple3[Long,Long,Double]] = input_rdd.map(
        line => line.split(',').toList
    ).map{
            e => (e(0).toLong, e(1).toLong, e(2).toDouble)
    }

    // Convert RDD[Tuple3] to RDD[MatrixEntry]
    val coo_matrix_matrixEntry: RDD[MatrixEntry] = coo_matrix_input.map(e => MatrixEntry(e._1, e._2, e._3))

    // Convert RDD[MatrixEntry] to CoordinateMatrix
    val coo_matrix: CoordinateMatrix  = new CoordinateMatrix(coo_matrix_matrixEntry)

    return coo_matrix
}

// ################# Repo-Lang ####################################

// Load and parse Sparse Matrix
// val repo_lang_rdd = sc.textFile("../Dataset/sample/dataset-01.txt",2000)
val repo_lang_rdd = sc.textFile("../Dataset/small/repo_lang_prob_sparse_small.csv",2000)


// Convert RDD[String] to CoordinateMatrix
val repo_lang_coo_matrix: CoordinateMatrix = rddToCoordinateMatrix(repo_lang_rdd)

// Transpose CoordinateMatrix
val repo_lang_coo_trans: CoordinateMatrix = repo_lang_coo_matrix.transpose()

// Convert CoordinateMatrix to BlockMatrix
val repo_lang_block_matrix: BlockMatrix = repo_lang_coo_trans.toBlockMatrix().cache()

println("RepoMatrix = (%d , %d)".format(repo_lang_block_matrix.numRows, repo_lang_block_matrix.numCols))

// ################# User-Lang ####################################

// Load and parse Sparse Matrix
// val user_lang_rdd = sc.textFile("../Dataset/sample/dataset-02.txt",2000)
val user_lang_rdd = sc.textFile("../Dataset/small/user_lang_prob_sparse_small.csv",2000)

// Convert RDD[String] to CoordinateMatrix
val user_lang_coo_matrix: CoordinateMatrix = rddToCoordinateMatrix(user_lang_rdd)

// Convert CoordinateMatrix to BlockMatrix
var user_lang_block_matrix: BlockMatrix = user_lang_coo_matrix.toBlockMatrix().cache()

println("UserMatrix = (%d , %d)".format(user_lang_block_matrix.numRows, user_lang_block_matrix.numCols))

// ################ Multiplication of two matrices #################

// Calculate ratings of each repos w.r.t each user i.e Rt = U*R
val ratings_block_matrix: BlockMatrix = user_lang_block_matrix.multiply(repo_lang_block_matrix)

println("RatingMatrix = (%d , %d)".format(ratings_block_matrix.numRows, ratings_block_matrix.numCols))

// Convert BlockMatrix to CoordinateMatrix
val ratings_coo_matrix: CoordinateMatrix = ratings_block_matrix.toCoordinateMatrix()

// CoordinateMatrix to RDD[MatrixEntry]
val ratings_rdd_entries = ratings_coo_matrix.entries

// Write rating matrix to output directory in csv format
val ratings_rdd = ratings_rdd_entries.map(line => line.i+","+line.j+","+((math rint line.value * 1000) / 1000))

ratings_rdd.saveAsTextFile("/media/kodekracker/Dell USB Portable HDD/Dataset/rating_output")
// ratings_rdd.saveAsTextFile("../Dataset/sample/rating_output")

// Close the REPL terminal
System.exit(0)
