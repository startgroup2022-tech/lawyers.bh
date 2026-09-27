# ProGuard/R8 Rules for Lawyers.bh

# Keep Flutter/Dart symbols
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep Riverpod
-keep class com.riverpod.** { *; }

# Keep Dio
-keep class retrofit2.** { *; }
-keep class okhttp3.** { *; }
-keep class com.google.gson.** { *; }

# Keep Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Keep serialization
-keep class **.*$$* { *; }
-keep class **.*$* { *; }

# Keep models (Freezed)
-keep class lawyers_bh.data.models.** { *; }

# Keep Riverpod providers
-keep class lawyers_bh.presentation.providers.** { *; }

# Keep entities
-keep class lawyers_bh.domain.entities.** { *; }

# Keep use cases
-keep class lawyers_bh.domain.usecases.** { *; }

# Keep repositories
-keep class lawyers_bh.data.repositories.** { *; }

# Keep network
-keep class lawyers_bh.core.network.** { *; }

# Keep storage
-keep class lawyers_bh.core.storage.** { *; }

# Keep router
-keep class lawyers_bh.core.router.** { *; }

# Keep theme
-keep class lawyers_bh.core.theme.** { *; }

# Keep constants
-keep class lawyers_bh.core.constants.** { *; }

# Don't warn about Flutter internal
-dontwarn io.flutter.**
-dontwarn io.flutter.plugins.**

# Optimize
-optimizationpasses 5
-allowaccessmodification
-dontpreverify