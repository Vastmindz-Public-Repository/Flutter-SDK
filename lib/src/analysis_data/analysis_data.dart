import 'dart:convert';

AnalysisData analysisDataFromJson(String str) => AnalysisData.fromJson(json.decode(str));

String analysisDataToJson(AnalysisData data) => json.encode(data.toJson());

class AnalysisData {
    String accessToken;
    int progressPercentage;
    List<int> signals;
    BloodPressure bloodPressure;
    int avgRespirationRate;
    String statusMessage;
    double snr;
    RateWarning rateWarning;
    double rmssd;
    int avgO2SaturationLevel;
    bool isMovingWarning;
    int avgBpm;
    String bloodPressureStatus;
    String statusCode;
    double ibi;
    String stressStatus;
    String? afibRiskStatus;
    double sdnns;

    AnalysisData({
        required this.accessToken,
        required this.progressPercentage,
        required this.signals,
        required this.bloodPressure,
        required this.avgRespirationRate,
        required this.statusMessage,
        required this.snr,
        required this.rateWarning,
        required this.rmssd,
        required this.avgO2SaturationLevel,
        required this.isMovingWarning,
        required this.avgBpm,
        required this.bloodPressureStatus,
        required this.statusCode,
        required this.ibi,
        required this.stressStatus,
        this.afibRiskStatus,
        required this.sdnns,
    });

    factory AnalysisData.fromJson(Map<String, dynamic> json) => AnalysisData(
        accessToken: json["accessToken"],
        progressPercentage: json["progressPercentage"],
        signals: List<int>.from(json["signals"].map((x) => x)),
        bloodPressure: BloodPressure.fromJson(json["bloodPressure"]),
        avgRespirationRate: json["avgRespirationRate"],
        statusMessage: json["statusMessage"],
        snr: json["snr"]?.toDouble(),
        rateWarning: RateWarning.fromJson(json["rateWarning"]),
        rmssd: json["rmssd"]?.toDouble(),
        avgO2SaturationLevel: json["avgO2SaturationLevel"],
        isMovingWarning: json["isMovingWarning"],
        avgBpm: json["avgBpm"],
        bloodPressureStatus: json["bloodPressureStatus"],
        statusCode: json["statusCode"],
        ibi: json["ibi"]?.toDouble(),
        stressStatus: json["stressStatus"],
        afibRiskStatus: json["afibRiskStatus"],
        sdnns: json["sdnns"]?.toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "accessToken": accessToken,
        "progressPercentage": progressPercentage,
        "signals": List<dynamic>.from(signals.map((x) => x)),
        "bloodPressure": bloodPressure.toJson(),
        "avgRespirationRate": avgRespirationRate,
        "statusMessage": statusMessage,
        "snr": snr,
        "rateWarning": rateWarning.toJson(),
        "rmssd": rmssd,
        "avgO2SaturationLevel": avgO2SaturationLevel,
        "isMovingWarning": isMovingWarning,
        "avgBpm": avgBpm,
        "bloodPressureStatus": bloodPressureStatus,
        "statusCode": statusCode,
        "ibi": ibi,
        "stressStatus": stressStatus,
        "afibRiskStatus": afibRiskStatus,
        "sdnns": sdnns,
    };
}

class BloodPressure {
    int systolic;
    int diastolic;

    BloodPressure({
        required this.systolic,
        required this.diastolic,
    });

    factory BloodPressure.fromJson(Map<String, dynamic> json) => BloodPressure(
        systolic: json["systolic"],
        diastolic: json["diastolic"],
    );

    Map<String, dynamic> toJson() => {
        "systolic": systolic,
        "diastolic": diastolic,
    };
}

class RateWarning {
    String notificationMessage;
    int delayValue;

    RateWarning({
        required this.notificationMessage,
        required this.delayValue,
    });

    factory RateWarning.fromJson(Map<String, dynamic> json) => RateWarning(
        notificationMessage: json["notificationMessage"],
        delayValue: json["delayValue"],
    );

    Map<String, dynamic> toJson() => {
        "notificationMessage": notificationMessage,
        "delayValue": delayValue,
    };
}