import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pixelvibe/data/repositories/media_repository.dart';
import 'package:pixelvibe/domain/services/media_scanner.dart';
import 'package:pixelvibe/services/scan_service.dart';
import 'package:pixelvibe/data/database/daos/video_metadata_dao.dart';

class MockVideoMetadataDao extends Mock implements VideoMetadataDao {}
class MockMediaScanner extends Mock implements MediaScanner {}
class MockScanService extends Mock implements ScanService {}

void main() {
  late MediaRepository repository;
  late MockVideoMetadataDao mockDao;
  late MockMediaScanner mockScanner;
  late MockScanService mockScanService;

  setUp(() {
    mockDao = MockVideoMetadataDao();
    mockScanner = MockMediaScanner();
    mockScanService = MockScanService();
    repository = MediaRepository(mockDao, mockScanner, mockScanService);

    when(() => mockScanner.videoExtensions).thenReturn(['mp4', 'mkv', 'webm']);
    when(() => mockDao.upsertBatch(any())).thenAnswer((_) async {});
  });

  group('MediaRepository.scanDevice', () {
    test('returns correctly mapped MediaFiles and caches them', () async {
      final rawVideos = [
        {
          'path': 'content://media/external/video/media/1',
          'filePath': '/storage/emulated/0/DCIM/Camera/VID_2023.mp4',
          'displayName': 'VID_2023.mp4',
          'durationMs': 15000,
          'width': 1920,
          'height': 1080,
          'size': 1024000,
          'lastModified': 1672531200000,
        },
        {
          'path': 'content://media/external/video/media/2',
          'filePath': '', // Fallback to content URI
          'displayName': 'DownloadVideo',
          'durationMs': 0,
          'width': null,
          'height': null,
          'size': 0,
          'lastModified': 0,
        }
      ];

      when(() => mockScanService.scanVideos()).thenAnswer((_) async => rawVideos);

      final files = await repository.scanDevice();

      expect(files, hasLength(2));
      expect(files[0].path, '/storage/emulated/0/DCIM/Camera/VID_2023.mp4');
      expect(files[0].name, 'VID_2023');
      expect(files[0].extension, 'mp4');
      expect(files[0].durationMs, 15000);
      
      expect(files[1].path, 'content://media/external/video/media/2');
      expect(files[1].name, 'DownloadVideo');
      expect(files[1].extension, '');

      // Verify caching
      expect(repository.isScanned, isTrue);
      verify(() => mockScanService.scanVideos()).called(1);

      // Call again, should not hit scan service
      final cachedFiles = await repository.scanDevice();
      expect(cachedFiles, equals(files));
      verifyNever(() => mockScanService.scanVideos());
    });

    test('filters out non-video extensions when filePath is present', () async {
      final rawVideos = [
        {
          'path': 'content://1',
          'filePath': '/storage/image.jpg',
          'displayName': 'image.jpg',
        },
        {
          'path': 'content://2',
          'filePath': '/storage/video.mkv',
          'displayName': 'video.mkv',
        }
      ];

      when(() => mockScanService.scanVideos()).thenAnswer((_) async => rawVideos);

      final files = await repository.scanDevice();

      expect(files, hasLength(1));
      expect(files.first.name, 'video');
      expect(files.first.extension, 'mkv');
    });

    test('forces scan when force is true', () async {
      when(() => mockScanService.scanVideos()).thenAnswer((_) async => []);

      await repository.scanDevice();
      await repository.scanDevice(force: true);

      verify(() => mockScanService.scanVideos()).called(2);
    });
  });

  group('MediaRepository.search', () {
    test('filters videos by name', () async {
      when(() => mockScanService.scanVideos()).thenAnswer((_) async => [
        {'filePath': '/v/apple.mp4', 'displayName': 'Apple'},
        {'filePath': '/v/banana.mp4', 'displayName': 'Banana'},
      ]);

      await repository.scanDevice();

      final results = repository.search('app');
      expect(results, hasLength(1));
      expect(results.first.name, 'Apple');
    });

    test('returns all videos if query is empty', () async {
      when(() => mockScanService.scanVideos()).thenAnswer((_) async => [
        {'filePath': '/v/apple.mp4', 'displayName': 'Apple'},
      ]);

      await repository.scanDevice();

      final results = repository.search('');
      expect(results, hasLength(1));
    });
  });
}
