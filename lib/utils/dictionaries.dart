library;


/// An action performed by POST /add_tags/add_tags request
enum AddTagsAction {
  addToLocalFileDomain(0),
  deleteFromLocalFileDomain(1),
  pendToTagRepository(2),
  rescindPendFromTagRepository(3),
  petitionFromTagRepository(4),
  rescindPetitionFromTagRepository(5);

  final int value;

  const AddTagsAction(this.value);
}


enum FileSortType {
  fileSize(0, 'size'),
  duration(1, 'duration'),
  importTime(2, 'import time'),
  // filetype(3, 'type'),
  random(4, 'random'),
  width(5, 'width'),
  height(6, 'height'),
  ratio(7, 'ratio'),
  numberOfPixels(8, 'number of pixels'),
  // numberOfTags(9, 'number of tags'),
  // numberOfMediaViews(10, 'number of views'),
  // totalMediaViewTime(11, 'view time'),
  // approximateBitrate(12, 'bitrate'),
  // hasAudio(13, 'has audio'),
  modifiedTime(14, 'modified time'),
  // frameRate(15, 'fps'),
  // numberOfFrames(16, 'number of frames'),
  // 17 doesn't exist
  // lastViewedTime(18, 'last viewed time'),
  // archiveTimestamp(19, 'archived time'),
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
