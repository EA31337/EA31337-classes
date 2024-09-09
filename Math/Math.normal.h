//+------------------------------------------------------------------+
//|                                                EA31337 framework |
//|                                 Copyright 2016-2023, EA31337 Ltd |
//|                                        https://ea31337.github.io |
//+------------------------------------------------------------------+

/*
 * This file is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#ifndef __MQL__
// Allows the preprocessor to include a header file when it is needed.
#pragma once
#endif

#ifndef USE_MQL_MATH_STAT
const static double normal_cdf_a[5] = {2.2352520354606839287E00, 1.6102823106855587881E02, 1.0676894854603709582E03,
                                       1.8154981253343561249E04, 6.5682337918207449113E-2};
const static double normal_cdf_b[4] = {4.7202581904688241870E01, 9.7609855173777669322E02, 1.0260932208618978205E04,
                                       4.5507789335026729956E04};
//--- coefficients for approximation in second interval
const static double normal_cdf_c[9] = {3.9894151208813466764E-1, 8.8831497943883759412E00, 9.3506656132177855979E01,
                                       5.9727027639480026226E02, 2.4945375852903726711E03, 6.8481904505362823326E03,
                                       1.1602651437647350124E04, 9.8427148383839780218E03, 1.0765576773720192317E-8};
const static double normal_cdf_d[8] = {2.2266688044328115691E01, 2.3538790178262499861E02, 1.5193775994075548050E03,
                                       6.4855582982667607550E03, 1.8615571640885098091E04, 3.4900952721145977266E04,
                                       3.8912003286093271411E04, 1.9685429676859990727E04};
//--- coefficients for approximation in third interval
const static double normal_cdf_p[6] = {2.1589853405795699E-1,   1.274011611602473639E-1, 2.2235277870649807E-2,
                                       1.421619193227893466E-3, 2.9112874951168792E-5,   2.307344176494017303E-2};
const static double normal_cdf_q[5] = {1.28426009614491121E00, 4.68238212480865118E-1, 6.59881378689285515E-2,
                                       3.78239633202758244E-3, 7.29751555083966205E-5};

//--- coefficients for p close to 0.5
const double normal_q_a0 = 3.3871328727963666080;
const double normal_q_a1 = 1.3314166789178437745E+2;
const double normal_q_a2 = 1.9715909503065514427E+3;
const double normal_q_a3 = 1.3731693765509461125E+4;
const double normal_q_a4 = 4.5921953931549871457E+4;
const double normal_q_a5 = 6.7265770927008700853E+4;
const double normal_q_a6 = 3.3430575583588128105E+4;
const double normal_q_a7 = 2.5090809287301226727E+3;
const double normal_q_b1 = 4.2313330701600911252E+1;
const double normal_q_b2 = 6.8718700749205790830E+2;
const double normal_q_b3 = 5.3941960214247511077E+3;
const double normal_q_b4 = 2.1213794301586595867E+4;
const double normal_q_b5 = 3.9307895800092710610E+4;
const double normal_q_b6 = 2.8729085735721942674E+4;
const double normal_q_b7 = 5.2264952788528545610E+3;
//--- coefficients for p not close to 0, 0.5 or 1
const double normal_q_c0 = 1.42343711074968357734;
const double normal_q_c1 = 4.63033784615654529590;
const double normal_q_c2 = 5.76949722146069140550;
const double normal_q_c3 = 3.64784832476320460504;
const double normal_q_c4 = 1.27045825245236838258;
const double normal_q_c5 = 2.41780725177450611770E-1;
const double normal_q_c6 = 2.27238449892691845833E-2;
const double normal_q_c7 = 7.74545014278341407640E-4;
const double normal_q_d1 = 2.05319162663775882187;
const double normal_q_d2 = 1.67638483018380384940;
const double normal_q_d3 = 6.89767334985100004550E-1;
const double normal_q_d4 = 1.48103976427480074590E-1;
const double normal_q_d5 = 1.51986665636164571966E-2;
const double normal_q_d6 = 5.47593808499534494600E-4;
const double normal_q_d7 = 1.05075007164441684324E-9;
//--- coefficients for p near 0 or 1.
const double normal_q_e0 = 6.65790464350110377720E0;
const double normal_q_e1 = 5.46378491116411436990E0;
const double normal_q_e2 = 1.78482653991729133580E0;
const double normal_q_e3 = 2.96560571828504891230E-1;
const double normal_q_e4 = 2.65321895265761230930E-2;
const double normal_q_e5 = 1.24266094738807843860E-3;
const double normal_q_e6 = 2.71155556874348757815E-5;
const double normal_q_e7 = 2.01033439929228813265E-7;
const double normal_q_f1 = 5.99832206555887937690E-1;
const double normal_q_f2 = 1.36929880922735805310E-1;
const double normal_q_f3 = 1.48753612908506148525E-2;
const double normal_q_f4 = 7.86869131145613259100E-4;
const double normal_q_f5 = 1.84631831751005468180E-5;
const double normal_q_f6 = 1.42151175831644588870E-7;
const double normal_q_f7 = 2.04426310338993978564E-15;
#endif
