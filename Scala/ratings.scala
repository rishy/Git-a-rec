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
val repo_lang_rdd = sc.textFile("../Dataset/sample/dataset-02.txt")

// Convert RDD[String] to CoordinateMatrix
val repo_lang_coo_matrix: CoordinateMatrix = rddToCoordinateMatrix(repo_lang_rdd)

// Convert CoordinateMatrix to BlockMatrix
var repo_lang_block_matrix: BlockMatrix = repo_lang_coo_matrix.toBlockMatrix().cache()


// ################# User-Lang ####################################

// Load and parse Sparse Matrix
val user_lang_rdd = sc.textFile("../Dataset/sample/dataset-01.txt")

// Convert RDD[String] to CoordinateMatrix
val user_lang_coo_matrix: CoordinateMatrix = rddToCoordinateMatrix(user_lang_rdd)

// Convert CoordinateMatrix to BlockMatrix
var user_lang_block_matrix: BlockMatrix = user_lang_coo_matrix.toBlockMatrix().cache()


// ################ Multiplication of two matrices #################

// Calculate ratings of each repos w.r.t each user i.e Rt = U*R
val ratings_block_matrix: BlockMatrix = user_lang_block_matrix.multiply(repo_lang_block_matrix)

// Convert BlockMatrix to CoordinateMatrix
val ratings_coo_matrix: CoordinateMatrix = ratings_block_matrix.toCoordinateMatrix()

// Write rating matrix to output directory in csv format
ratings_coo_matrix.entries.map(line => line.i+","+line.j+","+line.value).saveAsTextFile("../Dataset/rating_output")

// Close the REPL terminal
System.exit(0)
