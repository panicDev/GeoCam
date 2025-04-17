import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animations/animations.dart';
import '../providers/geocam_provider.dart';
import 'package:flutter/material.dart';

class GeoCamScreen extends StatelessWidget {
  const GeoCamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<GeoCamProvider>(
      builder: (context, geocamProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (geocamProvider.isLoading)
                Center(
                  child: CircularProgressIndicator(
                    color: colorScheme.primary,
                  ).animate()
                      .fadeIn(duration: 300.ms)
                      .rotate(duration: 2.seconds),
                ),

              if (geocamProvider.error != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    geocamProvider.error!,
                    style: TextStyle(color: colorScheme.onErrorContainer),
                  ),
                ).animate().shake().fadeIn(),

              // Location Section
              OpenContainer(
                transitionType: ContainerTransitionType.fade,
                openBuilder: (context, _) => _LocationDetailView(geocamProvider),
                closedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                closedElevation: 0,
                closedBuilder: (context, openContainer) => Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                    side: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  color: colorScheme.surfaceContainerLow,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Location',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (geocamProvider.hasLocation)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              'Latitude: ${geocamProvider.latitude}\nLongitude: ${geocamProvider.longitude}',
                              style: TextStyle(
                                fontSize: 16,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          )
                        else
                          Text(
                            'No location data available',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        const SizedBox(height: 20),
                        FilledButton.tonalIcon(
                          onPressed: geocamProvider.isLoading
                              ? null
                              : () => geocamProvider.getCurrentLocation(),
                          icon: const Icon(Icons.my_location_rounded),
                          label: const Text('Get Current Location'),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.5, end: 0, curve: Curves.easeOutQuad),

              const SizedBox(height: 16),

              // Camera Section
              OpenContainer(
                transitionType: ContainerTransitionType.fadeThrough,
                openBuilder: (context, _) => _PhotoDetailView(geocamProvider),
                closedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                closedElevation: 0,
                closedBuilder: (context, openContainer) => Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                    side: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  color: colorScheme.surfaceContainerLow,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.camera_alt_rounded,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Photo',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (geocamProvider.hasImage)
                          InkWell(
                            onTap: openContainer,
                            child: Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: colorScheme.shadow.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Hero(
                                tag: 'camera-photo',
                                child: Image.file(
                                  File(geocamProvider.imagePath!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          )
                        else
                          Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_outlined,
                                  size: 48,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'No image captured',
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 20),
                        FilledButton.tonalIcon(
                          onPressed: geocamProvider.isLoading
                              ? null
                              : () => geocamProvider.takePhoto(),
                          icon: const Icon(Icons.camera_alt_rounded),
                          label: const Text('Take Photo'),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate(delay: 200.ms).fadeIn(duration: 400.ms).slideY(begin: 0.5, end: 0, curve: Curves.easeOutQuad),

              const SizedBox(height: 32),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: (!geocamProvider.hasLocation ||
                          !geocamProvider.hasImage ||
                          geocamProvider.isLoading)
                          ? null
                          : () {
                        geocamProvider.saveData();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Data saved successfully!'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: colorScheme.primaryContainer,
                            showCloseIcon: true,
                            closeIconColor: colorScheme.onPrimaryContainer,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.save_rounded),
                      label: const Text('Save Data'),
                    ).animate(delay: 400.ms)
                        .fadeIn()
                        .move(begin: const Offset(-30, 0), end: Offset.zero),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: (!geocamProvider.hasLocation &&
                          !geocamProvider.hasImage) ||
                          geocamProvider.isLoading
                          ? null
                          : () {
                        geocamProvider.resetData();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Data reset successfully!'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: colorScheme.errorContainer,
                            showCloseIcon: true,
                            closeIconColor: colorScheme.onErrorContainer,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Reset Data'),
                    ).animate(delay: 500.ms)
                        .fadeIn()
                        .move(begin: const Offset(30, 0), end: Offset.zero),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LocationDetailView extends StatelessWidget {
  final GeoCamProvider provider;

  const _LocationDetailView(this.provider);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Details'),
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Location',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ).animate().fadeIn().slideX(begin: -50, end: 0),

            const SizedBox(height: 24),

            if (provider.hasLocation)
              Card(
                elevation: 0,
                color: colorScheme.surfaceContainerHighest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(
                        context: context,
                        icon: Icons.north_east_rounded,
                        label: 'Latitude',
                        value: '${provider.latitude}',
                      ),
                      Divider(color: colorScheme.outlineVariant),
                      _buildDetailRow(
                        context: context,
                        icon: Icons.north_west_rounded,
                        label: 'Longitude',
                        value: '${provider.longitude}',
                      ),
                    ],
                  ),
                ),
              ).animate(delay: 200.ms).fadeIn().scaleXY(begin: 0.8),

            if (!provider.hasLocation)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_off_rounded,
                        size: 84,
                        color: colorScheme.outline
                    ).animate().shake(),
                    const SizedBox(height: 16),
                    Text(
                      'No location data available',
                      style: TextStyle(
                        fontSize: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ).animate().fadeIn(delay: 200.ms),
                    const SizedBox(height: 32),
                    FilledButton.icon(
                      onPressed: () => provider.getCurrentLocation(),
                      icon: const Icon(Icons.my_location_rounded),
                      label: const Text('Get Location Now'),
                    ).animate().scale(delay: 400.ms),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 24, color: colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate(delay: 300.ms).fadeIn().move(begin: const Offset(50, 0), end: Offset.zero);
  }
}

class _PhotoDetailView extends StatelessWidget {
  final GeoCamProvider provider;

  const _PhotoDetailView(this.provider);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Photo Details'),
        backgroundColor: Colors.black.withOpacity(0.7),
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: provider.hasImage ? () {} : null,
          ),
        ],
      ),
      body: provider.hasImage
          ? Center(
        child: Hero(
          tag: 'camera-photo',
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Image.file(
              File(provider.imagePath!),
              fit: BoxFit.contain,
            ),
          ),
        ),
      )
          : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.no_photography_rounded,
              size: 64,
              color: Colors.white.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'No image available',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => provider.takePhoto(),
        icon: const Icon(Icons.camera_alt_rounded),
        label: const Text('New Photo'),
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
      ).animate().scale(delay: 300.ms),
    );
  }
}
