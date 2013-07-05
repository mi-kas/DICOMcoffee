// Generated by CoffeeScript 1.6.3
/*
@desc Implements the length measurement functionality. Lenght is calculated by using the PixelSpacing of the image and Pythagoras' theorem.
@author Michael Kaserer e1025263@student.tuwien.ac.at
@required All tools must implement following functions:
click(x, y, painters)
mousedown(x, y, painters)
mouseup(x, y, painters)
mousemove(x, y, painters)
mouseout(x, y, painters)
*/


(function() {
  this.Roi = (function() {
    var calculateDist, getPainterFromId;

    function Roi() {
      this.started = false;
      this.startX = 0;
      this.startY = 0;
      this.lineColor = '#0f0';
    }

    Roi.prototype.click = function() {};

    Roi.prototype.mousedown = function(x, y) {
      this.startX = x;
      this.startY = y;
      this.started = true;
      return this.lineColor = '#0f0';
    };

    Roi.prototype.mouseup = function(x, y, painters, target) {
      var context, dist, painter;
      if (this.started && this.startX !== x && this.startY !== y) {
        painter = getPainterFromId(target.id, painters);
        context = painter.context;
        dist = calculateDist(painter, this.startX, this.startY, x, y);
        context.font = '.8em Helvetica';
        context.fillStyle = this.lineColor;
        context.fillText(dist, x + 3, y + 3);
      }
      return this.started = false;
    };

    Roi.prototype.mousemove = function(x, y, painters, target) {
      var context, painter;
      if (this.started) {
        painter = getPainterFromId(target.id, painters);
        context = painter.context;
        getPainterFromId(target.id, painters).drawImg();
        context.beginPath();
        context.moveTo(this.startX, this.startY);
        context.lineTo(x, y);
        context.strokeStyle = this.lineColor;
        context.stroke();
        return context.closePath();
      }
    };

    Roi.prototype.mouseout = function() {
      return this.started = false;
    };

    getPainterFromId = function(id, painters) {
      var painter, _i, _len;
      for (_i = 0, _len = painters.length; _i < _len; _i++) {
        painter = painters[_i];
        if (painter.canvas.id === id) {
          return painter;
        }
      }
      return null;
    };

    calculateDist = function(painter, startX, startY, endX, endY) {
      var a, b, pixelSpacing;
      pixelSpacing = painter.currentFile.PixelSpacing ? painter.currentFile.PixelSpacing : [1, 1];
      a = (endX - startX) * pixelSpacing[0] / painter.getScale();
      b = (endY - startY) * pixelSpacing[1] / painter.getScale();
      return "" + ((Math.sqrt(Math.pow(a, 2) + Math.pow(b, 2)) / 10).toFixed(3)) + " cm";
    };

    return Roi;

  })();

}).call(this);
