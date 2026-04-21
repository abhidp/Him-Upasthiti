# PROJECT CONTEXT

This is an UNPACKED Android APK, NOT a standard programming project.
There is no compiler here. You cannot run 'gradle', 'mvn', or 'java'.

# STRICT LANGUAGE RULES

- The app logic is in the `smali/` folders.
- You MUST write and edit ONLY in Smali (Android Dalvik Bytecode assembly).
- NEVER suggest Java, Kotlin, or standard Android SDK code.
- If you don't know the exact Smali instruction, admit it. Do not guess.

# FILE STRUCTURE

- `smali/` = Code logic (similar to .java files, but ends in .smali).
- `res/` = Resources (XML layouts, strings, images).
- `AndroidManifest.xml` = App permissions and component declarations.

# YOUR JOB

When I ask for a tweak, find the corresponding `.smali` file or XML file, analyze the existing Smali registers (v0, v1, p0, p1, etc.), and provide the exact modified Smali code block or XML change.
