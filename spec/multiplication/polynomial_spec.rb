require 'spec_helper'

module Multiplication
  class Polynomial
    context "initialization" do
      it "truncates leading zeroes" do
        expect(Multiplication::Polynomial.new([1, 0]).to_s).to eq "1"
      end

      it "doesn't like empty arrays" do
        expect { Multiplication::Polynomial.new([]) }.to raise_error("Coefficients array is empty!")
      end
    end
    
    context "to_s" do
      def test_string_conversion(coefficients, expected_string)
        test_polynomial = Multiplication::Polynomial.new(coefficients)
        expect(test_polynomial.to_s).to eq expected_string
      end
      
      it "converts polynomials as expected" do
        test_string_conversion([3,1,2], "2x^2 + x + 3")
        test_string_conversion([-3,1,2], "2x^2 + x - 3")
        test_string_conversion([3,0,2], "2x^2 + 3")
        test_string_conversion([0,0,2], "2x^2")
        test_string_conversion([-3,0,0], "-3")
        test_string_conversion([-3,1.0,2], "2x^2 + x - 3")
        test_string_conversion([3, 1, 2, 0], "2x^2 + x + 3")
        test_string_conversion([3, 1, -2], "-2x^2 + x + 3")
      end
    end

    context "naive multiplication" do
      def test_multiply(coefficients1, coefficients2, expected_coefficients)
        p1 = Multiplication::Polynomial.new(coefficients1)
        p2 = Multiplication::Polynomial.new(coefficients2)
        expected_polynomial = Multiplication::Polynomial.new(expected_coefficients)
        expect((p1 * p2).to_s).to eq expected_polynomial.to_s
      end

      it "multiplies polynomials as expected" do
        test_multiply([3,1,2], [2], [6,2,4])
        test_multiply([3,1,2], [2,1,4], [6,5,17,6,8])
      end
    end

    context "fast fourier transform" do
      it "transforms to points correctly 1" do
        p = Multiplication::Polynomial.new([3,1,2])
        omega = p.calculate_root_of_unity(4)
        inputs = (0..3).to_a.map { |i| omega ** i }
        expected = inputs.map { |input| p.evaluate_at(input) }
        expect(p.fast_fourier_transform([3,1,2])).to eq expected
      end

      it "transforms to points correctly 2" do
        test_coefficients = [84,93,76,59,15,69,92,38,47,29]
        p = Multiplication::Polynomial.new(test_coefficients)

        omega = p.calculate_root_of_unity(16)
        inputs = (0..15).to_a.map { |i| omega ** i }

        expected = inputs.map { |input| p.evaluate_at(input) }
        expect(p.fast_fourier_transform(test_coefficients)).to eq expected
      end

      it "transforms and back 1" do
        p = Multiplication::Polynomial.new([3,1,2])
        expect(p.inverse_fast_fourier_transform(p.fast_fourier_transform([3,1,2]))).to eq [3,1,2,0]
      end

      it "transforms and back 2" do
        test_coefficients = [84,93,76,59,15,69,92,38,47,29]
        p = Multiplication::Polynomial.new(test_coefficients)
        expect(p.inverse_fast_fourier_transform(p.fast_fourier_transform(test_coefficients))).to eq test_coefficients
      end

      it "transforms and back 3" do
        test_coefficients = [7434,3061,6846,7415,3591,9425,2049,6044,711,3245,895,3745,5031,6010,8634,2743,9100,2038,5012,6335,4568,7409,6721,8129,5093,985,8495,8099,1956,7759,3911,5606,5161,3051,2585,6067,5485,6059,8202,5885,3147,1520,9579,8209,7138,3810,8741,1821,4323,1909,8590,875,5542,7593,7092,2485,7971,8052,1646,694,4578,3303,463,3155,7283,1601,4468,174,3993,6930,6247,5672,9572,923,1372,2847,4986,4380,9001,5339,3864,8401,5125,2232,8714,8871,8134,3074,6163,2677,5119,935,8861,2749,8228,144,7744,2989,9170,7763,9684,8037,7930,5818,2893,1820,959,7303,2984,6310,4218,7067,4331,26,5445,9068,3593,9510,5292,9053,3343,1108,8887,8067,2145,5402,4423,4366,5235,3288,1180,9370,7671,5901,9255,7074,949,580,8791,2708,7090,6927,6198,9387,7109,6143,7831,6748,5397,3540,9411,9923,3086,4528,3392,2160,5945,9333,7062,1302,5421,3675,5909,512,518,5035,5848,7332,4901,818,2868,7102,8392,1357,6013,93,7215,7969,9256,4084,4891,7465,5000,7336,9620,702,838,7661,7472,7105,2624,6302,9475,2060,1104,1734,5820,9817,3326,3398,1482,9854,167,1401,1130,6077,2965,6960,8797,8491,4964,5955,6071,8891,4428,5621,5911,1301,3273,4329,214,2644,6151,7242,8621,7946,3541,4210,7663,2085,4336,2652,6807,6692,3483,5500,6545,7945,1043,153,2748,539,96,1132,2328,4670,4810,4961,7184,6836,6292,5964,6161,3459,913,7284,6329,2050,5538,9377,1244,6449,3862,2092,291,7871,8728,9921,2133,5994,8922,6197,9836,5167,1540,497,6094,2886,7881,9730,6489,783,6558,573,4811,5708,6589,6170,65,2589,2666,7208,2793,2257,1965,1229,8194,2682,6971,9780,3735,3396,9656,8175,958,6351,8489,3574,7922,7371,6612,892,2294,4127,706,7470,8315,9465,566,7771,7186,4705,6824,2538,6944,5823,8463,9044,2198,3626,8188,5814,5422,2374,8858,316,3580,8754,2154,8738,7352,1632,2423,840,8664,3657,3570,9292,7168,2769,5249,9649,6503,2304,8699,4463,1161,5942,730,5271,5357,8977,2970,7163,5067,814,6805,130,4384,7328,3077,7205,3609,2934,7460,143,862,4917,3816,8164,5630,2279,303,3014,5982,5805,9625,9470,5754,1604,8988,414,4995,5148,1500,9745,5864,430,220,9160,3025,9702,5435,3611,3689,6733,61,5024,5461,6373,540,4514,4089,1314,8640,1442,7306,2313,9304,5580,1213,2874,9559,2689,149,1270,1291,7963,3743,3427,2894,8742,901,9575,402,8007,6009,9937,3910,1536,6985,3554,5390,509,8671,2468,6468,7457,7477,7236,6591,5498,7869,2784,7793,8626,1704,9000,4405,423,4166,2608,3770,1279,2857,683,8860,8913,9316,2980,6928,712,8608,774,4162,6438,6865,2228,805,9926,8758,4581,1879,6248,5310,1699,1407,9151,9938,9336,308,5277,7497,4797,1195,2995,6117,5695,8215,1067,9457,2508,7294,2827,7886,8055,7872,3053,5804,5867,8370,2296,3847,6497,454,6668,6754,5375,9286,6445,4588,7323,8724,9629,1994,4002,2105,8920,3767,2453,265,6017,9235,713,390,2775,2117,9239,7213,7091,3224,8496,5859,8185,9310,7174,5767,8349,8923,9558,8371,7870,7721,6811,5389,720,2200,6164,9237,528,2686,1433,8301,8832,2188,4032,3251,2425,7000,2266,225,2436,5552,5587,1800,2331,152,5995,5150,5790,9669,2306,5126,4408,1902,9205,8732,1810,866,8706,7052,7747,3902,8530,9697,5136,1187,5040,2744,7655,8158,3342,6595,9223,9717,7733,6153,7804,48,9683,6119,4793,3296,272,7511,8655,5417,7631,404,4293,1760,5836,1437,4342,3470,6512,1885,4745,5302,9422,4960,3829,112,1465,3026,9328,8531,2383,5484,8456,9200,2918,7908,6685,1218,6214,3442,5247,6959,3031,1727,9980,8044,4787,7469,6461,6686,8627,5107,2218,525,7098,2047,3756,2601,533,3984,6911,692,1527,5628,9573,1107,6313,8802,3950,7624,9761,8596,1383,158,2445,3549,5755,9364,6755,456,2245,1547,4723,8445,6111,6698,4370,9771,256,2178,9835,7211,358,7055,8819,1003,4128,9643,687,8143,7850,940,1191,1124,4684,6937,1425,2132,6700,326,4383,821,5003,9693,5728,5998,5392,3123,5371,2820,4006,6447,2948,1983,3050,4390,7868,3395,9282,7518,1517,4550,3504,8710,9217,5372,6287,3669,3011,2176,1164,4991,5684,8287,1094,9899,8144,3449,2586,5242,9564,1845,9482,5269,1564,8102,5825,1083,787,2870,5002,2944,224,267,9159,8238,1895,2974,825,5678,1770,5686,8661,570,1576,246,9973,6124,8536,6108,7278,9382,8739,2745,7107,5930,2366,3869,3781,6588,8231,1208,2530,5314,8180,7176,925,6317,3283,4301,3300,5460,9064,946,1907,6232,5915,6654,9733,8942,8022,1593,3428,9659,1974,3187,8881,6719,1183,6697,5169,5250,8998,7362,365,9028,6427,6261,993,1716,9583,2225,6858,3304,1535,7257,9190,4749,7422,3525,6075,4474,2149,9514,9390,1515,8476,2020,9929,1410,1260,4928,6600,3406,3456,4033,7959,1084,4821,5104,7738,5128,8051,5475,5803,5784,2199,6395,9535,8285,3822,4753,2189,1553,8544,5329,9203,4101,620,5792,1393,7436,1186,5004,4491,5530,6107,1248,3926,8836,829,929,8509,6965,6717,6244,1738,1173,1344,8551,1644,5872,2841,476,7443,4630,2454,4386,2019,7822,2577,7185,6961,6191,1254,9928,2648,1395,7017,5595,5355,9680,3621,7380,10,7650,2230,8587,5139,1272,7607,1403,6756,1048,9635,5032,6977,8013,9865,3,4295,7962,6852,2111,4750,3613,8377,3393,8796,8283,6458,6221,3550,7207,2805,5608,8895,2529,6867,4732,5946,5807,7665,2925,2489,7492,7121,3797,1870,4393,7455,9090,1283,4990,7745,2488,2982,1865,7526,3646,3518,8629,9799,9500,7160,9640,9307,1307,7877,5474,4011,1903,613]

        p = Multiplication::Polynomial.new(test_coefficients)
        expect(p.inverse_fast_fourier_transform(p.fast_fourier_transform(test_coefficients))).to eq test_coefficients
      end
    end
  end
end
