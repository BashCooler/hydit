class Action {
  static const addToLocalFileDomain = 0;
  static const deleteFromLocalFileDomain = 1;
  static const pendToTagRepository = 2;
  static const rescindPendFromTagRepository = 3;
  static const petitionFromTagRepository = 4;
  static const rescindPetitionFromTagRepository = 5;
}


class BasicPermission {
  static const importAndEditURLs = 0;
  static const importAndDeleteFiles = 1;
  static const editFileTags = 2;
  static const searchForAndFetchFiles = 3;
  static const managePages = 4;
  static const manageCookiesAndHeaders = 5;
  static const manageDatabase = 6;
  static const editFileNotes = 7;
  static const editFileRelationships = 8;
  static const editFileRatings = 9;
  static const managePopups = 10;
  static const editFileTimes = 11;
  static const commitPending = 12;
  static const seeLocalPaths = 13;
}


enum FileSortType {
  fileSize(0, 'size'),
  duration(1, 'duration'),  // should work, but haven't been tested really
  importTime(2, 'import time'),
  // filetype(3, 'type'),
  random(4, 'random'),
  width(5, 'width'),
  height(6, 'height'),
  ratio(7, 'ratio'),
  numberOfPixels(8, 'number of pixels'),
  // numberOfTags(9, 'number of tags'),  // doesn't work
  // numberOfMediaViews(10, 'number of views'),
  // totalMediaViewTime(11, 'view time'),
  // approximateBitrate(12, 'bitrate'),
  hasAudio(13, 'has audio'),
  modifiedTime(14, 'modified time'),
  // frameRate(15, 'fps'),
  // numberOfFrames(16, 'number of frames'),
  // 17 doesn't exist
  // lastViewedTime(18, 'last viewed time'),
  // archiveTimestamp(19, 'archived time'),  // doesn't work
  // hashHex(20, 'has hex'),
  // pixelHashHex(21, 'pixel hash hex'),
  // blurHash(22, 'blur hash'),
  // averageColourLightness(22, 'avg color lightness'),
  // averageColourChromaticMagnitude(23, 'avg color chromatic magnitude'),
  // averageColourGreenRedAxis(24, 'avg color green red axis'),
  // averageColourBlueYellowAxis(25, 'avg color blue yellow axis'),
  // averageColourHue(26, 'avg color hue');
  ;

  final int value;
  final String name;

  const FileSortType(this.value, this.name);
}