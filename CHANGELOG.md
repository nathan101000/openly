# [1.4.0](https://github.com/nathan101000/openly/compare/v1.3.0...v1.4.0) (2025-08-06)


### Features

* **ui:** add animated splash screen with fingerprint scan and unlock sequence ([a7730cf](https://github.com/nathan101000/openly/commit/a7730cf5598a5bfa40f09b5e9d4390c4708d3fda))

# [1.3.0](https://github.com/nathan101000/openly/compare/v1.2.0...v1.3.0) (2025-08-05)


### Features

* **settings:** replace profile screen with redesigned settings screen ([a660308](https://github.com/nathan101000/openly/commit/a6603087bc26a1c6e7e0460ff608df05979f0dc3))

# [1.2.0](https://github.com/nathan101000/openly/compare/v1.1.1...v1.2.0) (2025-08-05)


### Features

* **profile:** add manual update check button with feedback dialog ([7bfbda4](https://github.com/nathan101000/openly/commit/7bfbda42f9beb4caacc383a4d83a32428eaf6386))

## [1.1.1](https://github.com/nathan101000/openly/compare/v1.1.0...v1.1.1) (2025-08-05)


### Bug Fixes

* **android:** disable minify and shrinkResources in release build ([fe219d0](https://github.com/nathan101000/openly/commit/fe219d0e7a2adca7397b131083ac6305e65ba3ee))

# [1.1.0](https://github.com/nathan101000/openly/compare/v1.0.0...v1.1.0) (2025-08-04)


### Features

* **update:** add in-app OTA update support with GitHub release integration ([ceb8227](https://github.com/nathan101000/openly/commit/ceb82274ee72307ca8b22fa7cc589d988877f14f))

# 1.0.0 (2025-08-04)


## 🚀 Initial Release

Openly is a smart door access app built with Flutter. This first stable release includes:

- 🔐 **Authentication system** with local biometric support  
- 🧭 **Responsive navigation** using `NavigationRail`  
- 🕒 **Timed door unlock** functionality with feedback animations  
- 🎨 **Material 3 expressive design**  
- 🧑‍💼 **User profile and settings**  
- ⚙️ Robust error handling and token expiry management


### Bug Fixes

* add .vscode/launch.json to .gitignore ([7937d5f](https://github.com/nathan101000/openly/commit/7937d5f1264493bd7824a5b986fcc86ad5a14cf0))
* add missing native android dir ([64289f4](https://github.com/nathan101000/openly/commit/64289f408732af47f32d8593a71da97255ab48f7))
* ensure default theme is system and handle null theme values ([5cf0080](https://github.com/nathan101000/openly/commit/5cf0080f5c671b8f4e21e1b26a23a21daf672128))
* reset pubspec version to 0.0.0 after rebase ([875d9e5](https://github.com/nathan101000/openly/commit/875d9e5e7d07d1b697f62ca95e849c0554e15c65))


### Features

* add flutter_lints package and remove unused import ([f9f1734](https://github.com/nathan101000/openly/commit/f9f17346b58eb3ec2082394cf5f621001074ca4a))
* add local_auth and improve floor name parsing ([0655eeb](https://github.com/nathan101000/openly/commit/0655eebcca36cf5b88e9237f6459e1046e255c42))
* apply Material 3 expressive redesign ([a2bba85](https://github.com/nathan101000/openly/commit/a2bba8520314ef1c3d47c3832629a64ac085c7c0))
* enhance door unlock functionality with timed unlock and UI improvements ([be1907a](https://github.com/nathan101000/openly/commit/be1907a1584ac31205e447a5fdd5997d2e99ffde))
* enhance home screen, profile, and auth service ([78a5c8c](https://github.com/nathan101000/openly/commit/78a5c8cda9845d70ddd23d9bd4cf20e89882d8b9))
* enhance login screen with password visibility toggle and autofill ([71c8c26](https://github.com/nathan101000/openly/commit/71c8c268d68363fbc52f3649fe3d3ab7c0f658e1))
* Implement door access control app with authentication and theming ([a86026b](https://github.com/nathan101000/openly/commit/a86026b39db15e43977c242d1b64ba52fc6f2582))
* implement responsive navigation with NavigationRail ([6adcd70](https://github.com/nathan101000/openly/commit/6adcd704789e374c63e90cdbb67cd67bcf321b42))
* implement token expiry for authentication ([fd800e6](https://github.com/nathan101000/openly/commit/fd800e6636a3f1e5e9ff010cb6259159bd4260cf))
* improve error handling and user feedback ([a92bcf7](https://github.com/nathan101000/openly/commit/a92bcf77dad9e768654a2f460eab3a7d88347075))
* restructure main screen with tabs and favorites ([17d7531](https://github.com/nathan101000/openly/commit/17d7531f3e9db5b6e1af3a26056d5abf7d2ca873))
