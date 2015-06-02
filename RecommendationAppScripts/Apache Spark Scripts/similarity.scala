import org.apache.spark.mllib.linalg.{Vector, Vectors}
import org.apache.spark.mllib.linalg.distributed.{RowMatrix, MatrixEntry, CoordinateMatrix}
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

// Read CSV File to RDD[String]
val input_rdd: RDD[String] = sc.textFile("../Dataset/small/user_lang_prob_sparse_small.csv")

// Read RDD[String] to CoordinateMatrix
val coo_matrix = rddToCoordinateMatrix(input_rdd)

// Transpose CoordinateMatrix
val coo_matrix_trans = coo_matrix.transpose()

// Convert CoordinateMatrix to RowMatrix
val mat: RowMatrix = coo_matrix_trans.toRowMatrix()

// Compute similar columns perfectly, with brute force
// Return CoordinateMatrix
val simsPerfect: CoordinateMatrix = mat.columnSimilarities()

// CoordinateMatrix to RDD[MatrixEntry]
val simsPerfect_entries = simsPerfect.entries

// Write results to file
val results_rdd = simsPerfect_entries.map(line => line.i+","+line.j+","+(line.value-(line.value % 0.001)))

results_rdd.saveAsTextFile("../Dataset/small/similarity-output")

// Close the REPL terminal
System.exit(0)
