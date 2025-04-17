import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animations/animations.dart';
import '../cubits/geocam/geocam_cubit.dart';
import '../cubits/geocam/geocam_state.dart';

class GeoCamScreen extends StatelessWidget {
  const GeoCamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<GeoCamCubit, GeoCamState>(
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Progress indicator
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: LinearProgressIndicator(
                      value: _calculateProgress(state),
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                      minHeight: 8,
                    ),
                  ).animate().fadeIn(duration: 400.ms),

                  // Loading indicator
                  if (state.isLoading)
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
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
                  if (state.error != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(16),
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
                            color: colorScheme.error,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: colorScheme.onError,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Error',
                                  style: TextStyle(
                                    color: colorScheme.onError,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    color: colorScheme.onError,
                                  ),
                                  onPressed: () {
                                    context.read<GeoCamCubit>().clearError();
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
                              state.error!,
                              style: TextStyle(
                                color: colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16).copyWith(top: 0),
                            child: FilledButton.tonal(
                              onPressed: () {
                                context.read<GeoCamCubit>().clearError();
                              },
                              child: const Text('Try Again'),
                            ),
                          ),
                        ],
                      ),
                    ).animate().shake().fadeIn(),

                  // Location Section
                  _buildLocationCard(context, state, colorScheme),
                  const SizedBox(height: 20),

                  // Camera Section
                  _buildCameraCard(context, state, colorScheme),
                  const SizedBox(height: 20),

                  // Action Buttons Section
                  _buildActionsCard(context, state, colorScheme),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Location Card
  Widget _buildLocationCard(BuildContext context, GeoCamState state, ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(
          color: state.hasLocation
              ? colorScheme.primary
              : colorScheme.outlineVariant,
          width: state.hasLocation ? 1.5 : 1.0,
        ),
      ),
      color: state.hasLocation
          ? colorScheme.primaryContainer
          : colorScheme.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: state.hasLocation
                            ? colorScheme.primary
                            : colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.location_on_rounded,
                        color: state.hasLocation
                            ? colorScheme.onPrimary
                            : colorScheme.outline,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Location',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          state.hasLocation
                              ? 'Location data captured'
                              : 'No location data yet',
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (state.hasLocation)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: colorScheme.onPrimary,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              children: [
                if (state.hasLocation)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLocationItem(
                          context: context,
                          title: 'Latitude',
                          value: '${state.latitude}',
                          icon: Icons.north_east_rounded,
                          colorScheme: colorScheme,
                        ),
                        Divider(color: colorScheme.outlineVariant),
                        _buildLocationItem(
                          context: context,
                          title: 'Longitude',
                          value: '${state.longitude}',
                          icon: Icons.north_west_rounded,
                          colorScheme: colorScheme,
                        ),
                      ],
                    ),
                  )
                else
                  _buildEmptyLocationState(context, colorScheme),
                
                const SizedBox(height: 16),
                FilledButton.tonalIcon(
                  onPressed: state.isLoading
                      ? null
                      : () => context.read<GeoCamCubit>().getCurrentLocation(),
                  icon: const Icon(Icons.my_location_rounded),
                  label: Text(state.hasLocation ? 'Update Location' : 'Get Current Location'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  // Camera Card
  Widget _buildCameraCard(BuildContext context, GeoCamState state, ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(
          color: state.hasImage
              ? colorScheme.secondary
              : colorScheme.outlineVariant,
          width: state.hasImage ? 1.5 : 1.0,
        ),
      ),
      color: state.hasImage
          ? colorScheme.secondaryContainer
          : colorScheme.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: state.hasImage
                            ? colorScheme.secondary
                            : colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.camera_alt_rounded,
                        color: state.hasImage
                            ? colorScheme.onSecondary
                            : colorScheme.outline,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Photo',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          state.hasImage ? 'Photo captured' : 'No photo taken yet',
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (state.hasImage)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: colorScheme.onSecondary,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),

          // Photo container
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                    border: !state.hasImage
                        ? Border.all(color: colorScheme.outlineVariant)
                        : null,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: state.hasImage
                      ? Hero(
                          tag: 'camera-photo',
                          child: Image.file(
                            File(state.imagePath!),
                            fit: BoxFit.cover,
                          ),
                        )
                      : _buildEmptyCameraState(context, colorScheme),
                ),
                
                const SizedBox(height: 16),
                FilledButton.tonalIcon(
                  onPressed: state.isLoading
                      ? null
                      : () => context.read<GeoCamCubit>().takePhoto(),
                  icon: const Icon(Icons.camera_alt_rounded),
                  label: Text(state.hasImage ? 'Replace Photo' : 'Take Photo'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  // Actions Card
  Widget _buildActionsCard(BuildContext context, GeoCamState state, ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0).copyWith(bottom: 8),
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
                      _getActionSubtitle(state),
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
                  isComplete: state.hasLocation,
                  colorScheme: colorScheme,
                ),
                _buildRequirementItem(
                  context: context,
                  title: 'Photo taken',
                  isComplete: state.hasImage,
                  colorScheme: colorScheme,
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
                    onPressed: (!state.hasLocation || !state.hasImage || state.isLoading)
                        ? null
                        : () {
                            context.read<GeoCamCubit>().saveData();
                            _showSuccessDialog(context, colorScheme);
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
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: (!state.hasLocation && !state.hasImage) || state.isLoading
                        ? null
                        : () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Reset Data?'),
                                content: const Text(
                                  'This will clear all captured photos and location data.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: const Text('Cancel'),
                                  ),
                                  FilledButton(
                                    onPressed: () {
                                      context.read<GeoCamCubit>().resetData();
                                      Navigator.of(context).pop();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: const Row(
                                            children: [
                                              Icon(Icons.refresh_rounded, color: Colors.white),
                                              SizedBox(width: 12),
                                              Text('Data reset successfully!'),
                                            ],
                                          ),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text('Reset'),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: colorScheme.error,
                                      foregroundColor: colorScheme.onError,
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
                      side: BorderSide(color: colorScheme.outline, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.1, end: 0);
  }

  // Empty location state widget
  Widget _buildEmptyLocationState(BuildContext context, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.location_off_outlined,
            size: 36,
            color: colorScheme.onSurfaceVariant,
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
  Widget _buildEmptyCameraState(BuildContext context, ColorScheme colorScheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_a_photo_outlined,
          size: 36,
          color: colorScheme.onSurfaceVariant,
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
    required ColorScheme colorScheme,
  }) {
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
              color: isComplete ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
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

  // Location item with better visual styling
  Widget _buildLocationItem({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required ColorScheme colorScheme,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: colorScheme.onPrimary),
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

  // Success dialog with animation
  void _showSuccessDialog(BuildContext context, ColorScheme colorScheme) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
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
                onPressed: () => Navigator.pop(context),
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

  // Loading animation
  Widget _buildLoadingAnimation(ColorScheme colorScheme) {
    return Container(
      width: 48,
      height: 48,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        shape: BoxShape.circle,
      ),
      child: CircularProgressIndicator(
        color: colorScheme.onPrimary,
        strokeWidth: 3,
      ).animate().fadeIn(duration: 300.ms).rotate(duration: 2.seconds),
    );
  }

  // Calculate progress for progress bar
  double _calculateProgress(GeoCamState state) {
    int steps = 0;
    if (state.hasLocation) steps++;
    if (state.hasImage) steps++;
    return steps / 2;
  }

  // Get subtitle based on completion status
  String _getActionSubtitle(GeoCamState state) {
    if (!state.hasLocation && !state.hasImage) {
      return 'Complete both steps to continue';
    } else if (!state.hasLocation) {
      return 'Missing location data';
    } else if (!state.hasImage) {
      return 'Missing photo';
    } else {
      return 'All requirements met';
    }
  }
}