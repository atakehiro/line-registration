import ij.*;
import ij.process.*;
import ij.gui.*;
import java.awt.*;
import ij.plugin.*;
import ij.plugin.frame.*;

public class batch_LineReg_2ch_1chTarget implements PlugIn {

	public void run(String arg) {
		int num = 30;
		int range_x = 15;
		ImagePlus imp = IJ.getImage();
		String title = imp.getTitle();
		IJ.log("Start 2 channel line registration of " + title);
		IJ.log("Range is " + range_x);
		IJ.log("Mean filter size is " + num);
		IJ.log("Target channel is first channel");
        ImageStack ist = imp.getStack();
        int width = ist.getWidth();
        int height = ist.getHeight();
        int sliceNum = ist.getSize();
        for (int t = 1; t <= sliceNum/2; t++) {
        	IJ.log("Slice number is " + t);
	        ImageProcessor ip1 = ist.getProcessor(2*t-1);
	        ImageProcessor ip2 = ist.getProcessor(2*t);
	        double[][] imgArray1 = new double[width][height];
	        for (int y = 0; y < height; y++) for (int x = 0; x < width; x++) imgArray1[x][y] = ip1.get(x,y);
	        double[][] imgArray2 = new double[width][height];
	        for (int y = 0; y < height; y++) for (int x = 0; x < width; x++) imgArray2[x][y] = ip2.get(x,y);
	        int[] opt_dif_line = new int[height];
	        opt_dif_line[0] = 0;
	        int pre_dif = 0;
	        for (int i = 1; i < height; i++) {
	        	double[] line1 = new double[width];
	        	for (int x = 0; x < width; x++) line1[x] = imgArray1[x][i-1];
	        	double[] line2 = new double[width];
	        	for (int x = 0; x < width; x++) line2[x] = imgArray1[x][i];
		        double xcorr[] = new double[2*range_x + 1];
		        for (int j = 0; j < 2*range_x + 1; j++) {
		        	double line2_1[] = new double[width];
		        	for (int k = 0; k < width; k++) line2_1[k] = 0.0;
		 			int dif = j - range_x;
		        	if (dif < 0) {
		        		System.arraycopy(line2, -dif, line2_1, 0, width + dif);
					} else {
		    			System.arraycopy(line2, 0, line2_1, dif, width - dif);
					} 
					xcorr[j] = coef(line1, line2_1);
		        }
		        double max = 0.0;
		        int opt_idx = 0;
                for(int j = 0; j < xcorr.length; j++){
                	if (xcorr[j] > max) {
                	opt_idx = j;
                	max = xcorr[j];
					}
                }
				int opt_dif = pre_dif + opt_idx - range_x;
				opt_dif_line[i] = opt_dif;
				pre_dif = opt_dif;
	        }
	        int start, end;
	        for (int i = 1; i < height; i++) {
	        	start = i - num/2;
	        	end = i + num/2;
	        	if (start < 0) start = 0;
	        	if (end > height) end = height;
	        	int sum = 0;
	        	for (int j = start; j < end; j++) sum += opt_dif_line[j];
	            int opt_dif2 = opt_dif_line[i] - sum/(end - start);
	        	double[] C1_line = new double[width];
	        	for (int x = 0; x < width; x++) C1_line[x] = imgArray1[x][i];
				double C1_line2[] = new double[width];
				for (int k = 0; k < width; k++) C1_line2[k] = 0.0;
				if (opt_dif2 < 0) {	
		    		System.arraycopy(C1_line, -opt_dif2, C1_line2, 0, width + opt_dif2);
				} else {
					System.arraycopy(C1_line, 0, C1_line2, opt_dif2, width - opt_dif2);
				}
				double[] C2_line = new double[width];
	        	for (int x = 0; x < width; x++) C2_line[x] = imgArray2[x][i];
				double C2_line2[] = new double[width];
				for (int k = 0; k < width; k++) C2_line2[k] = 0.0;
				if (opt_dif2 < 0) {	
		    		System.arraycopy(C2_line, -opt_dif2, C2_line2, 0, width + opt_dif2);
				} else {
					System.arraycopy(C2_line, 0, C2_line2, opt_dif2, width - opt_dif2);
				}
				for (int j = 0; j < width; j++) {
					ip1.set(j, i, (int)C1_line2[j]);
					ip2.set(j, i, (int)C2_line2[j]);
				}
	        }
        }
        IJ.log("Finish 2 channel line registration of " + title);
        IJ.log("Range is " + range_x);
        IJ.log("Mean filter size is " + num);
	  IJ.log("Target channel is first channel");
        imp.setTitle("Yreged_" + title);
        imp.updateAndDraw();
	}

	private double coef(double[] vector1, double[] vector2) {
        int n = vector1.length;
        double sum1 = 0.0, sum2 = 0.0;
        for (int i = 0; i < n; i++){
            sum1 += vector1[i];
            sum2 += vector2[i];
        }
        double mean1 = sum1/n, mean2 = sum2/n;
        double sum11 = 0.0, sum12 = 0.0, sum22 = 0.0;
        for (int i = 0; i < n; i++){
            sum11 += (vector1[i] - mean1) * (vector1[i] - mean1);
            sum22 += (vector2[i] - mean2) * (vector2[i] - mean2);
            sum12 += (vector1[i] - mean1) * (vector2[i] - mean2);
        }
	    double variance1 = sum11 / n, variance2 = sum22 / n;
        double cov = sum12 / n;
        double sd1 = Math.sqrt(variance1), sd2 = Math.sqrt(variance2);
        double coef = cov / (sd1 * sd2);
        return coef;
    }

}
