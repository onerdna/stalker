/* 
 * Stalker
 * Copyright (C) 2025 Andreno
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 */

class GitHub {
  static const String repoUser = "onerdna";
  static const String repoName = "stalker";
  static const String repoUrl = "https://github.com/$repoUser/$repoName";
  static const String latestRelease = "$repoUrl/releases/latest";
  static const String issueFeatureRequest =
      "$repoUrl/issues/new?template=feature_request.md";
  static const String issueAdditionalSetup =
      "$repoUrl/issues/new?template=additional-setup-bug-report.md";
  static const String issueGeneral =
      "$repoUrl/issues/new?template=general-bug-report.md";
}
