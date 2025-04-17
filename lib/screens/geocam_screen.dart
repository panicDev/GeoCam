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
        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.photo_camera_rounded,
                    color: colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'GeoCam',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            centerTitle: false,
            actions: [
              // Help button
              IconButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => _buildHelpSheet(context),
                  );
                },
                icon: Icon(
                  Icons.help_outline_rounded,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                tooltip: 'Help & Info',
              ),
              // Status indicator with animation
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        geocamProvider.hasLocation && geocamProvider.hasImage
                            ? colorScheme.primaryContainer
                            : colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (
                          Widget child,
                          Animation<double> animation,
                        ) {
                          return ScaleTransition(
                            scale: animation,
                            child: child,
                          );
                        },
                        child: Icon(
                          geocamProvider.hasLocation && geocamProvider.hasImage
                              ? Icons.check_circle_rounded
                              : Icons.pending_rounded,
                          key: ValueKey<bool>(
                            geocamProvider.hasLocation &&
                                geocamProvider.hasImage,
                          ),
                          size: 16,
                          color:
                              geocamProvider.hasLocation &&
                                      geocamProvider.hasImage
                                  ? colorScheme.primary
                                  : colorScheme.outline,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        geocamProvider.hasLocation && geocamProvider.hasImage
                            ? 'Ready'
                            : 'Incomplete',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color:
                              geocamProvider.hasLocation &&
                                      geocamProvider.hasImage
                                  ? colorScheme.onPrimaryContainer
                                  : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            scrolledUnderElevation: 0,
            backgroundColor: colorScheme.surface,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Progress indicator
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: LinearProgressIndicator(
                      value: _calculateProgress(geocamProvider),
                      backgroundColor: colorScheme.surfaceVariant,
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                      minHeight: 8,
                    ),
                  ).animate().fadeIn(duration: 400.ms),

                  // Loading indicator
                  if (geocamProvider.isLoading)
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colorScheme.primary.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          _buildLoadingAnimation(colorScheme),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Processing Request',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Please wait while we process your request...',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Error message with dismiss button
                  if (geocamProvider.error != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.shadow.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            color: colorScheme.error.withOpacity(0.1),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: colorScheme.error,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Error',
                                  style: TextStyle(
                                    color: colorScheme.error,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    color: colorScheme.error,
                                  ),
                                  onPressed: () {
                                    // Clear error
                                    geocamProvider.clearError();
                                  },
                                  iconSize: 18,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 24,
                                    minHeight: 24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              geocamProvider.error!,
                              style: TextStyle(
                                color: colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16).copyWith(top: 0),
                            child: FilledButton.tonal(
                              onPressed: () {
                                // Suggest retry action
                                geocamProvider.clearError();
                              },
                              child: const Text('Try Again'),
                            ),
                          ),
                        ],
                      ),
                    ).animate().shake().fadeIn(),

                  // Location Section
                  Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.shadow.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: OpenContainer(
                          transitionType: ContainerTransitionType.fade,
                          openBuilder:
                              (context, _) =>
                                  _LocationDetailView(geocamProvider),
                          closedShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          closedElevation: 0,
                          closedColor: Colors.transparent,
                          closedBuilder:
                              (context, openContainer) => Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                  side: BorderSide(
                                    color:
                                        geocamProvider.hasLocation
                                            ? colorScheme.primary.withOpacity(
                                              0.3,
                                            )
                                            : colorScheme.outlineVariant,
                                    width:
                                        geocamProvider.hasLocation ? 1.5 : 1.0,
                                  ),
                                ),
                                color:
                                    geocamProvider.hasLocation
                                        ? colorScheme.primaryContainer
                                            .withOpacity(0.15)
                                        : colorScheme.surfaceContainerLow,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(28),
                                  onTap: openContainer,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Header with gradient
                                      Container(
                                        padding: const EdgeInsets.all(24.0),
                                        decoration: BoxDecoration(
                                          gradient:
                                              geocamProvider.hasLocation
                                                  ? LinearGradient(
                                                    colors: [
                                                      colorScheme
                                                          .primaryContainer
                                                          .withOpacity(0.5),
                                                      colorScheme
                                                          .primaryContainer
                                                          .withOpacity(0.1),
                                                    ],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  )
                                                  : null,
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                top: Radius.circular(28),
                                              ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(
                                                    10,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        geocamProvider
                                                                .hasLocation
                                                            ? colorScheme
                                                                .primary
                                                                .withOpacity(
                                                                  0.2,
                                                                )
                                                            : colorScheme
                                                                .surfaceVariant,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          16,
                                                        ),
                                                  ),
                                                  child: Icon(
                                                    Icons.location_on_rounded,
                                                    color:
                                                        geocamProvider
                                                                .hasLocation
                                                            ? colorScheme
                                                                .primary
                                                            : colorScheme
                                                                .outline,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Location',
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            colorScheme
                                                                .onSurface,
                                                      ),
                                                    ),
                                                    Text(
                                                      geocamProvider.hasLocation
                                                          ? 'Location data captured'
                                                          : 'No location data yet',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color:
                                                            colorScheme
                                                                .onSurfaceVariant,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            if (geocamProvider.hasLocation)
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  8,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: colorScheme.primary
                                                      .withOpacity(0.1),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  Icons.check_rounded,
                                                  color: colorScheme.primary,
                                                  size: 20,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),

                                      // Content
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          24,
                                          0,
                                          24,
                                          24,
                                        ),
                                        child: Column(
                                          children: [
                                            if (geocamProvider.hasLocation)
                                              Container(
                                                width: double.infinity,
                                                padding: const EdgeInsets.all(
                                                  16,
                                                ),
                                                decoration: BoxDecoration(
                                                  color:
                                                      colorScheme
                                                          .surfaceContainerHighest,
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  border: Border.all(
                                                    color:
                                                        colorScheme
                                                            .outlineVariant,
                                                    width: 0.5,
                                                  ),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    _buildEnhancedLocationItem(
                                                      context: context,
                                                      title: 'Latitude',
                                                      value:
                                                          '${geocamProvider.latitude}',
                                                      icon:
                                                          Icons
                                                              .north_east_rounded,
                                                    ),
                                                    Divider(
                                                      color:
                                                          colorScheme
                                                              .outlineVariant,
                                                      height: 24,
                                                    ),
                                                    _buildEnhancedLocationItem(
                                                      context: context,
                                                      title: 'Longitude',
                                                      value:
                                                          '${geocamProvider.longitude}',
                                                      icon:
                                                          Icons
                                                              .north_west_rounded,
                                                    ),
                                                  ],
                                                ),
                                              )
                                            else
                                              _buildEmptyLocationState(context),
                                            const SizedBox(height: 20),
                                            FilledButton.tonalIcon(
                                              onPressed:
                                                  geocamProvider.isLoading
                                                      ? null
                                                      : () =>
                                                          geocamProvider
                                                              .getCurrentLocation(),
                                              icon: const Icon(
                                                Icons.my_location_rounded,
                                              ),
                                              label: Text(
                                                geocamProvider.hasLocation
                                                    ? 'Update Location'
                                                    : 'Get Current Location',
                                              ),
                                              style: FilledButton.styleFrom(
                                                minimumSize: const Size(
                                                  double.infinity,
                                                  48,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuad),

                  // Camera Section
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: OpenContainer(
                      transitionType: ContainerTransitionType.fadeThrough,
                      openBuilder:
                          (context, _) => _PhotoDetailView(geocamProvider),
                      closedShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      closedElevation: 0,
                      closedColor: Colors.transparent,
                      closedBuilder:
                          (context, openContainer) => Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                              side: BorderSide(
                                color:
                                    geocamProvider.hasImage
                                        ? colorScheme.secondary.withOpacity(0.3)
                                        : colorScheme.outlineVariant,
                                width: geocamProvider.hasImage ? 1.5 : 1.0,
                              ),
                            ),
                            color:
                                geocamProvider.hasImage
                                    ? colorScheme.secondaryContainer
                                        .withOpacity(0.15)
                                    : colorScheme.surfaceContainerLow,
                            child: InkWell(
                              onTap:
                                  geocamProvider.hasImage
                                      ? openContainer
                                      : null,
                              borderRadius: BorderRadius.circular(28),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header with gradient
                                  Container(
                                    padding: const EdgeInsets.all(24.0),
                                    decoration: BoxDecoration(
                                      gradient:
                                          geocamProvider.hasImage
                                              ? LinearGradient(
                                                colors: [
                                                  colorScheme.secondaryContainer
                                                      .withOpacity(0.5),
                                                  colorScheme.secondaryContainer
                                                      .withOpacity(0.1),
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              )
                                              : null,
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(28),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color:
                                                    geocamProvider.hasImage
                                                        ? colorScheme.secondary
                                                            .withOpacity(0.2)
                                                        : colorScheme
                                                            .surfaceVariant,
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              child: Icon(
                                                Icons.camera_alt_rounded,
                                                color:
                                                    geocamProvider.hasImage
                                                        ? colorScheme.secondary
                                                        : colorScheme.outline,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Photo',
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        colorScheme.onSurface,
                                                  ),
                                                ),
                                                Text(
                                                  geocamProvider.hasImage
                                                      ? 'Photo captured'
                                                      : 'No photo taken yet',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color:
                                                        colorScheme
                                                            .onSurfaceVariant,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        if (geocamProvider.hasImage)
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: colorScheme.secondary
                                                  .withOpacity(0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.check_rounded,
                                              color: colorScheme.secondary,
                                              size: 20,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),

                                  // Photo container
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      24,
                                      0,
                                      24,
                                      24,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: 220,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color:
                                                colorScheme
                                                    .surfaceContainerHighest,
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            boxShadow:
                                                geocamProvider.hasImage
                                                    ? [
                                                      BoxShadow(
                                                        color: colorScheme
                                                            .shadow
                                                            .withOpacity(0.15),
                                                        blurRadius: 12,
                                                        offset: const Offset(
                                                          0,
                                                          6,
                                                        ),
                                                      ),
                                                    ]
                                                    : null,
                                            border:
                                                !geocamProvider.hasImage
                                                    ? Border.all(
                                                      color:
                                                          colorScheme
                                                              .outlineVariant,
                                                      width: 1,
                                                      strokeAlign:
                                                          BorderSide
                                                              .strokeAlignInside,
                                                    )
                                                    : null,
                                          ),
                                          clipBehavior: Clip.antiAlias,
                                          child:
                                              geocamProvider.hasImage
                                                  ? Stack(
                                                    children: [
                                                      Positioned.fill(
                                                        child: Hero(
                                                          tag: 'camera-photo',
                                                          child: Image.file(
                                                            File(
                                                              geocamProvider
                                                                  .imagePath!,
                                                            ),
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                      // Image overlay
                                                      Positioned(
                                                        top: 8,
                                                        right: 8,
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 10,
                                                                vertical: 6,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                  0.6,
                                                                ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  16,
                                                                ),
                                                          ),
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .touch_app_rounded,
                                                                color:
                                                                    Colors
                                                                        .white,
                                                                size: 16,
                                                              ),
                                                              const SizedBox(
                                                                width: 4,
                                                              ),
                                                              Text(
                                                                'View',
                                                                style: TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                  : _buildEmptyCameraState(
                                                    context,
                                                  ),
                                        ),
                                        const SizedBox(height: 20),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: FilledButton.tonalIcon(
                                                onPressed:
                                                    geocamProvider.isLoading
                                                        ? null
                                                        : () =>
                                                            geocamProvider
                                                                .takePhoto(),
                                                icon: const Icon(
                                                  Icons.camera_alt_rounded,
                                                ),
                                                label: Text(
                                                  geocamProvider.hasImage
                                                      ? 'Replace Photo'
                                                      : 'Take Photo',
                                                ),
                                                style: FilledButton.styleFrom(
                                                  minimumSize: const Size(
                                                    0,
                                                    48,
                                                  ),
                                                  backgroundColor:
                                                      colorScheme
                                                          .secondaryContainer,
                                                  foregroundColor:
                                                      colorScheme
                                                          .onSecondaryContainer,
                                                ),
                                              ),
                                            ),
                                            if (geocamProvider.hasImage) ...[
                                              const SizedBox(width: 12),
                                              IconButton.filledTonal(
                                                onPressed: () {
                                                  // Open photo for viewing
                                                  openContainer();
                                                },
                                                icon: const Icon(
                                                  Icons.fullscreen_rounded,
                                                ),
                                                tooltip: 'View Full Image',
                                                style: IconButton.styleFrom(
                                                  backgroundColor: colorScheme
                                                      .secondaryContainer
                                                      .withOpacity(0.7),
                                                  foregroundColor:
                                                      colorScheme
                                                          .onSecondaryContainer,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    ),
                  ).animate(delay: 200.ms).fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuad),

                  // Action Buttons with advancement check
                  Card(
                    elevation: 0,
                    color: colorScheme.surfaceContainerLowest,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(
                            20.0,
                          ).copyWith(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: colorScheme.tertiaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.check_circle_outline_rounded,
                                  color: colorScheme.onTertiaryContainer,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Finalize Your Capture',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _getActionSubtitle(geocamProvider),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Checklist
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              _buildRequirementItem(
                                context: context,
                                title: 'Location data',
                                isComplete: geocamProvider.hasLocation,
                              ),
                              _buildRequirementItem(
                                context: context,
                                title: 'Photo taken',
                                isComplete: geocamProvider.hasImage,
                              ),
                            ],
                          ),
                        ),

                        // Action Buttons
                        Padding(
                          padding: const EdgeInsets.all(20.0).copyWith(top: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: FilledButton.icon(
                                      onPressed:
                                          (!geocamProvider.hasLocation ||
                                                  !geocamProvider.hasImage ||
                                                  geocamProvider.isLoading)
                                              ? null
                                              : () {
                                                geocamProvider.saveData();
                                                _showSuccessDialog(
                                                  context,
                                                  colorScheme,
                                                );
                                              },
                                      icon: const Icon(Icons.save_rounded),
                                      label: const Text('Save Data'),
                                      style: FilledButton.styleFrom(
                                        minimumSize: const Size(0, 50),
                                        textStyle: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    )
                                    .animate(delay: 400.ms)
                                    .fadeIn()
                                    .move(
                                      begin: const Offset(-30, 0),
                                      end: Offset.zero,
                                    ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed:
                                      (!geocamProvider.hasLocation &&
                                                  !geocamProvider.hasImage) ||
                                              geocamProvider.isLoading
                                          ? null
                                          : () {
                                            showDialog(
                                              context: context,
                                              builder:
                                                  (context) => AlertDialog(
                                                    title: Text('Reset Data?'),
                                                    content: Text(
                                                      'This will clear all captured photos and location data.',
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed:
                                                            () =>
                                                                Navigator.of(
                                                                  context,
                                                                ).pop(),
                                                        child: Text('Cancel'),
                                                      ),
                                                      FilledButton(
                                                        onPressed: () {
                                                          geocamProvider
                                                              .resetData();
                                                          Navigator.of(
                                                            context,
                                                          ).pop();
                                                          ScaffoldMessenger.of(
                                                            context,
                                                          ).showSnackBar(
                                                            SnackBar(
                                                              content: Row(
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .refresh_rounded,
                                                                    color:
                                                                        colorScheme
                                                                            .onErrorContainer,
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 12,
                                                                  ),
                                                                  const Text(
                                                                    'Data reset successfully!',
                                                                  ),
                                                                ],
                                                              ),
                                                              behavior:
                                                                  SnackBarBehavior
                                                                      .floating,
                                                              backgroundColor:
                                                                  colorScheme
                                                                      .errorContainer,
                                                              showCloseIcon:
                                                                  true,
                                                              closeIconColor:
                                                                  colorScheme
                                                                      .onErrorContainer,
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      10,
                                                                    ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        child: Text('Reset'),
                                                        style:
                                                            FilledButton.styleFrom(
                                                              backgroundColor:
                                                                  colorScheme
                                                                      .error,
                                                              foregroundColor:
                                                                  colorScheme
                                                                      .onError,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                            );
                                          },
                                  icon: const Icon(Icons.refresh_rounded),
                                  label: const Text('Reset Data'),
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(0, 50),
                                    textStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    side: BorderSide(
                                      color: colorScheme.outline,
                                      width: 1.5,
                                    ),
                                  ),
                                ).animate(delay: 500.ms).fadeIn().move(begin: const Offset(30, 0), end: Offset.zero),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.3, end: 0),

                  SizedBox(
                    height: MediaQuery.of(context).padding.bottom > 0 ? 0 : 16,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Calculate progress for progress bar
  double _calculateProgress(GeoCamProvider provider) {
    int steps = 0;
    if (provider.hasLocation) steps++;
    if (provider.hasImage) steps++;
    return steps / 2;
  }

  // Get subtitle based on completion status
  String _getActionSubtitle(GeoCamProvider provider) {
    if (!provider.hasLocation && !provider.hasImage) {
      return 'Complete both steps to continue';
    } else if (!provider.hasLocation) {
      return 'Missing location data';
    } else if (!provider.hasImage) {
      return 'Missing photo';
    } else {
      return 'All requirements met';
    }
  }

  // Animated loading indicator
  Widget _buildLoadingAnimation(ColorScheme colorScheme) {
    return Container(
      width: 48,
      height: 48,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: CircularProgressIndicator(
        color: colorScheme.primary,
        strokeWidth: 3,
      ).animate().fadeIn(duration: 300.ms).rotate(duration: 2.seconds),
    );
  }

  // Help bottom sheet
  Widget _buildHelpSheet(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 5,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.outline.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'How to use GeoCam',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHelpItem(
                    context: context,
                    icon: Icons.location_on_rounded,
                    title: 'Location',
                    description:
                        'Capture your current GPS coordinates by tapping the "Get Current Location" button.',
                  ),
                  _buildHelpItem(
                    context: context,
                    icon: Icons.camera_alt_rounded,
                    title: 'Photo',
                    description:
                        'Take a photo using your device camera by tapping the "Take Photo" button.',
                  ),
                  _buildHelpItem(
                    context: context,
                    icon: Icons.save_rounded,
                    title: 'Save',
                    description:
                        'Once both location and photo are captured, save the data to your device.',
                  ),
                  _buildHelpItem(
                    context: context,
                    icon: Icons.refresh_rounded,
                    title: 'Reset',
                    description:
                        'Clear all captured data and start over if needed.',
                  ),
                  const SizedBox(height: 16),
                  Divider(),
                  const SizedBox(height: 16),
                  Text(
                    'About GeoCam',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'GeoCam allows you to capture and store photos with precise location data for documentation, field surveys, and other location-based applications.',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Got it'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Empty location state widget
  Widget _buildEmptyLocationState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              shape: BoxShape.circle,
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Icon(
              Icons.location_off_outlined,
              size: 36,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Location Data',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to get your current location coordinates',
            textAlign: TextAlign.center,
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // Empty camera state widget
  Widget _buildEmptyCameraState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            shape: BoxShape.circle,
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Icon(
            Icons.add_a_photo_outlined,
            size: 36,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'No Image Captured',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Use your camera to take a photo',
          textAlign: TextAlign.center,
          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
        ),
      ],
    );
  }

  // Requirement checklist item
  Widget _buildRequirementItem({
    required BuildContext context,
    required String title,
    required bool isComplete,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isComplete ? colorScheme.primary : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: isComplete ? colorScheme.primary : colorScheme.outline,
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.check,
              size: 14,
              color: isComplete ? colorScheme.onPrimary : Colors.transparent,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              color:
                  isComplete
                      ? colorScheme.onSurface
                      : colorScheme.onSurfaceVariant,
              fontWeight: isComplete ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
          const Spacer(),
          Icon(
            isComplete
                ? Icons.check_circle_outline_rounded
                : Icons.radio_button_unchecked_rounded,
            color: isComplete ? colorScheme.primary : colorScheme.outline,
            size: 20,
          ),
        ],
      ),
    );
  }

  // Enhanced location item with better visual styling
  Widget _buildEnhancedLocationItem({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: colorScheme.primary),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurfaceVariant,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Help item for the help sheet
  Widget _buildHelpItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: colorScheme.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Success dialog with confetti animation
  void _showSuccessDialog(BuildContext context, ColorScheme colorScheme) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Success icon with animated circle
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: colorScheme.onPrimaryContainer,
                      size: 40,
                    ),
                  ).animate().scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1.0, 1.0),
                    curve: Curves.elasticOut,
                    duration: 600.ms,
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Data Saved Successfully',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'Your photo and location data have been saved.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),

                  const SizedBox(height: 24),

                  FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ),
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
                    Icon(
                      Icons.location_off_rounded,
                      size: 84,
                      color: colorScheme.outline,
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
        )
        .animate(delay: 300.ms)
        .fadeIn()
        .move(begin: const Offset(50, 0), end: Offset.zero);
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
      body:
          provider.hasImage
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
