function lcaDiopters = wvfLCAFromWavelengthDifference(wl1NM,wl2NM,whichCalc,COMPARE)
% lcaDiopters = wvfLCAFromWavelengthDifference(wl1NM,wl2NM,[whichCalc],[COMPARE])
%
% Longitudinal chromatic aberration (LCA), expressed in diopters, between
% two wavelengths.
%
% Either input argument may be a vector, but if both are vectors they need
% to have the same dimensions.
%
% Optional argument whichCalc determines which of two numerical methods are used.
% They are supposed to give the same answer, and do to reasonable approximation.
% The differences are probably just numerical roundoff.
%   hoferCode  -  The way Heidi Hofer wrote it in the code she provided us with.
%   thibosPaper - The calculation as described in Thibos et al, 1992, "The
%                chromatic eye: ...", Applied Optics, 31, pp 3594-3600.
% The thibosPaper method is the default.
%
% If optional argument COMPARE is true, the routine prints out the maximum
% absolute difference between the methods.
%
% If the image is in focus at wl1NM, this provides the refractive error
% at wl2NM.  The sign convention matches that of Figure 6 the Thibos et al.%
% paper, so that (e.g.):
%   -1.7174 = wvfLCAFromWavelengthDifference(589,400,'thibosPaper');
%
% Here is what Heidi told wrote about her code:
%     The LCA is the difference in the focusing power of the eye at different wavelengths.
%     The majority of the eye's refracting power comes from the air/cornea interface, and
%     to a first approximation the eye can be treated like a ball of water.
%     For a single surface like this the power (one over focal length) is proportional
%     to the curvature and the index of refraction (minus 1 if the cornea is in air) - higher
%     curvature corneas focus more and so have shorter focal length, greater index of
%     refraction causes the rays to bend more as the enter the cornea and they focus
%     closer to the corneal surface.  The index of refraction varies with wavelength though,
%     so that shorter wavelengths always experience a higher index of refraction and bend more.
%     So there is always a difference in the power with wavelength:
% 
%      F(lamda1) = (n(lamda1)-1)*c
%      F(lamda2) = (n(lamda2)-1)*c
%      LCA(lamda2,lamda1) = F(lamda2)-F(lamda1) = c*[n(lamda2)-n(lamda1)]
% 
%     so you can see that the LCA (in this case written as a difference in power) between two
%     wavelengths is proportional to the corneal curvature as well as the difference in
%     corneal index of refraction at the two wavelengths.  In general the difference in
%     index of refraction across the visible spectrum for the eye is not all that large,
%     and very close to what you would expect if the eye were made of water.
%     [The numbers in the first 2 equations are taken from a paper by Larry Thibos and colleagues
%     (1992, Applied Optics, 31, pp. 3594-3600) mainly capture effective index variation of the eye
%     with wavelength - experimentally measured - which is very close to what has been measured for water.
%     The first equation just sets the constant in the second equation so that the dioptric difference is
%     zero at the nominal focus wavelength.
%
%     I do not believe you can derive the index variation analytically,
%     at least not without considering material physics that is way beyond me at this point, and for the
%     eye it may be impossible anyway given the additional contributions of the lens and other structures.
%     But since the corneal curvature is so high to begin with, even this small difference results in a pretty large
%     dioptric difference across the visible spectrum.  If we couldn't locate our retina at the
%     focal plane of the eye (or close anyway) we would never notice the LCA, but we can, so it is important.
%
%     [There will be a wavelength dependence of the higher order aberrations as well, which will probably
%     (depends somewhat more on where they are coming from since it is not such a good approximation
%     to assume they are all caused by the cornea) be of similar relative magnitude, ie maybe 4% or
%     so across the visible spectrum, but this is just not very noticeable at all unless you are able
%     to remove the mean aberration (as is the case with defocus), and even then it doesn't make sense
%     to consider this difference until such a time as our error in measurement decreases significantly -
%     this is why we only focus on LCA - and just let the other zernike terms stay constant with wavelength]
%
% We also implemented what we understood from the Thibos paper and verified that it gives the same answer to
% several places, with the difference probably attributable in rounding of the constants.
%
% The sign of the difference produced by this routine agrees with the figures in the Thibos paper.
%
% 8/21/11  dhb  Pulled out from code supplied by Heidi Hofer.
% 9/5/11   dhb  Rename.  Rewrite for wvfPrams i/o.
% 5/29/12  dhb  Pulled out just the bit that does the computation of diopters
% 7/24/12  dhb  Verify against Thibos paper formulae. 
% 7/29/12  dhb  Add optional args, make Thibos paper version default.  
%
% (c) Wavefront Toolbox Team 2011, 2012

%% Set which calculation to use
if (nargin < 3 || isempty(whichCalc))
    whichCalc = 'hoferCode';
end

if (nargin < 4 || isempty(COMPARE))
    COMPARE = 0;
end

%% Here's the magic from Heidi's code
constant = 1.8859 - (0.63346./(0.001.*wl1NM-0.2141));
lcaDioptersHoferCode = 1.8859 - constant - (0.63346./(0.001*wl2NM-0.2141));

%% The Thibos paper method
% Constants from the top of page 3596
rMM = 5.55 ;          % mm
rM = rMM*1e-3;
nD = 1.333;

% Constants from bottom of page 3596
a = 1.320535;
b = 0.004685;
c = 0.214102;

% Get refractive indices
wl1UM = wl1NM*1e-3;
wl2UM = wl2NM*1e-3;
n1 = a + b./(wl1UM-c);
n2 = a + b./(wl2UM-c);

% Use equation 1 and take the difference of the two deltas
% in diopters.
lcaDioptersThibosPaper = (n1 - n2)./(nD*rM);

switch (whichCalc)
    case 'hoferCode'
        lcaDiopters = lcaDioptersHoferCode;
        
    case 'thibosPaper'
        lcaDiopters = lcaDioptersThibosPaper;    
end



%% Compare the two versions
if (COMPARE)
    maxDiff = max(abs(lcaDioptersHoferCode-lcaDioptersThibosPaper));
    fprintf('Maximum LCA difference is %0.4g Diopters\n',maxDiff);  
end

return

%% Verification code.  Select and execute
wls = [400 450 500 570 700];
wls1 = 570*ones(size(wls));
lcaDiopters = wvfLCAFromWavelengthDifference(wls(1),wls,'hoferCode')
lcaDiopters = wvfLCAFromWavelengthDifference(wls(1),wls,'thibosPaper')
lcaDiopters = wvfLCAFromWavelengthDifference(wls1,wls,'hoferCode')
lcaDiopters = wvfLCAFromWavelengthDifference(wls1,wls,'thibosPaper')
lcaDiopters = wvfLCAFromWavelengthDifference(wls1,wls,[],true);
