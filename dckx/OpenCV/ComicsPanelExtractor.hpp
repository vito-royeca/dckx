//
//  ComicsPanelExtractor.hpp
//  dckx
//
//  Created by Vito Royeca on 3/23/21.
//  Copyright © 2021 Vito Royeca. All rights reserved.
//

#ifndef ComicsPanelExtractor_hpp
#define ComicsPanelExtractor_hpp

#include <stdio.h>
#include <opencv2/opencv.hpp>
#include <nlohmann_json/json.hpp>

using namespace cv;
using namespace std;
using json = nlohmann::json;

class ComicsPanelExtractor {
    
public:
    
    json splitComics(const std::string& path, const int minimumPanelSizeRatio);
private:
    
};

#endif /* ComicsPanelExtractor_hpp */

/*
 def get_contours(self,gray,filename,bgcol):
         
         thresh = None
         contours = None
         
         # White background: values below 220 will be black, the rest white
         if bgcol == 'white':
             ret,thresh = cv.threshold(gray,220,255,cv.THRESH_BINARY_INV)
             contours, hierarchy = cv.findContours(thresh, cv.RETR_EXTERNAL, cv.CHAIN_APPROX_SIMPLE)[-2:]
         
         elif bgcol == 'black':
             # Black background: values above 25 will be black, the rest white
             ret,thresh = cv.threshold(gray,25,255,cv.THRESH_BINARY)
             contours, hierarchy = cv.findContours(thresh, cv.RETR_EXTERNAL, cv.CHAIN_APPROX_SIMPLE)[-2:]
         
         else:
             raise Exception('Fatal error, unknown background color: '+str(bgcol))
         
         if self.options['debug_dir']:
             cv.imwrite(os.path.join(self.options['debug_dir'],os.path.basename(filename)+'-020-thresh[{}].jpg'.format(bgcol)),thresh)
         
         return contours
 
 def parse_image_with_bgcol(self,infos,filename,bgcol,url=None):
         
         contours = self.get_contours(self.gray,filename,bgcol)
         infos['background'] = bgcol
         
         # Get (square) panels out of contours
         contourSize = int(sum(infos['size']) / 2 * 0.004)
         panels = []
         for contour in contours:
             arclength = cv.arcLength(contour,True)
             epsilon = 0.001 * arclength
             approx = cv.approxPolyDP(contour,epsilon,True)
             
             panel = Panel(polygon=approx)
             
             # exclude very small panels
             if panel.w < infos['size'][0] * self.options['min_panel_size_ratio'] or panel.h < infos['size'][1] * self.options['min_panel_size_ratio']:
                 continue
             
             if self.options['debug_dir']:
                 cv.drawContours(self.img, [approx], 0, (0,0,255), contourSize)
             
             panels.append(Panel(polygon=approx))
         
         # See if panels can be cut into several (two non-consecutive points are close)
         self.split_panels(panels,self.img,contourSize)
         
         # Merge panels that shouldn't have been split (speech bubble diving in a panel)
         self.merge_panels(panels)
         
         # splitting polygons may result in panels slightly overlapping, de-overlap them
         self.deoverlap_panels(panels)
         
         # get actual gutters before expanding panels
         actual_gutters = Kumiko.actual_gutters(panels)
         infos['gutters'] = [actual_gutters['x'],actual_gutters['y']]
         
         panels.sort()  # TODO: remove
         self.expand_panels(panels)
         
         if len(panels) == 0:
             panels.append( Panel([0,0,infos['size'][0],infos['size'][1]]) );
         
         # Number panels comics-wise (left to right for now)
         panels.sort()
         
         # Simplify panels back to lists (x,y,w,h)
         panels = list(map(lambda p: p.to_xywh(), panels))
         
         infos['panels'] = panels
         
         # write panel numbers on debug image
         if self.options['debug_dir']:
             cv.imwrite(os.path.join(self.options['debug_dir'],os.path.basename(filename)+'-010-gray.jpg'),self.gray)
             cv.imwrite(os.path.join(self.options['debug_dir'],os.path.basename(filename)+'-040-contours.jpg'),self.img)
         
         return infos
 
 def parse_image(self,filename,url=None):
         self.img = cv.imread(filename)
         if not isinstance(self.img,np.ndarray) or self.img.size == 0:
             raise NotAnImageException('File {} is not an image'.format(filename))
         
         size = list(self.img.shape[:2])
         size.reverse()  # get a [width,height] list
         
         infos = {
             'filename': url if url else os.path.basename(filename),
             'size': size
         }
         
         # get license for this file
         if os.path.isfile(filename+'.license'):
             with open(filename+'.license') as fh:
                 try:
                     infos['license'] = json.load(fh)
                 except json.decoder.JSONDecodeError:
                     print('License file {} is not a valid JSON file'.format(filename+'.license'))
                     sys.exit(1)
         
         self.gray = cv.cvtColor(self.img,cv.COLOR_BGR2GRAY)
         
         for bgcol in ['white','black']:
             res = self.parse_image_with_bgcol(infos.copy(),filename,bgcol,url)
             if len(res['panels']) > 1:
                 return res
         
         return res
*/
